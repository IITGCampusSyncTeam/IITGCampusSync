import axios from "axios";
import qs from "querystring";
import AppError from "../../utils/appError.js";
import catchAsync from "../../utils/catchAsync.js";
import academicdata from "../../config/academic.js";
import dotenv from "dotenv";

dotenv.config();

const clientid = process.env.CLIENT_ID;
const clientSecret = process.env.CLIENT_SECRET;
const redirect_uri = process.env.REDIRECT_URI;

import { findUserWithEmail, getUserFromToken, validateUser } from "../user/user.model.js";
import User from "../user/user.model.js";

// Fetch department information using Microsoft Graph API
const getDepartment = async (access_token) => {
    const config = {
        method: "get",
        url: "https://graph.microsoft.com/beta/me/profile",
        headers: {
            Authorization: `Bearer ${access_token}`,
            "Content-Type": "application/x-www-form-urlencoded",
            Accept: "application/json",
        },
    };
    const response = await axios.get(config.url, { headers: config.headers });
    return response.data.positions[0]?.detail?.company?.department;
};

// Calculate semester based on roll number and academic year mapping
function calculateSemester(rollNumber) {
    const year = parseInt(rollNumber.slice(0, 2));
    return academicdata.semesterMap[year] || 1;
}

// Handle mobile redirect for authentication
export const mobileRedirectHandler = async (req, res, next) => {
    try {
        const { code } = req.query;

        const data = qs.stringify({
            client_secret: clientid, // Make sure this is loaded securely from env
            client_id: clientSecret,
            redirect_uri: redirect_uri,
            scope: "user.read",
            grant_type: "authorization_code",
            code: code,
        });

        const config = {
            method: "post",
            url: 'https://login.microsoftonline.com/850aa78d-94e1-4bc6-9cf3-8c11b530701c/oauth2/v2.0/token',
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                client_secret: 'yg48Q~GGKqo~Do7US0gLN7VJWK9gr0UqwriAKbv~', // Make sure this is loaded securely from env
            },
            data: data,
        };

        console.log("Config before Axios request:", config);

        const response = await axios.post(config.url, config.data, { headers: config.headers });
        if (!response.data) throw new AppError(500, "Something went wrong");

        const accessToken = response.data.access_token;
        const RefreshToken = response.data.refresh_token;
        console.log("refresh token is: ",RefreshToken);
        const userFromToken = await getUserFromToken(accessToken);
        if (!userFromToken || !userFromToken.data) throw new AppError(401, "Access Denied");

        const rollNumber = userFromToken.data.surname;
        if (!rollNumber) throw new AppError(401, "Sign in using Institute Account");

        let existingUser = await findUserWithEmail(userFromToken.data.mail);
        if (!existingUser) {
            const department = await getDepartment(accessToken);
            const userData = {
                name: userFromToken.data.displayName,
                email: userFromToken.data.mail,
                rollNumber: rollNumber,
                degree: userFromToken.data.jobTitle,
                semester: calculateSemester(rollNumber),
                department: department,
                role: 'normal', // default role
            };

            const { error } = validateUser(userData);
            if (error) throw new AppError(400, error.message);

            const newUser = new User(userData);
            existingUser = await newUser.save();
        }

        const token = existingUser.generateJWT();

        return res.redirect(`iitgsync://success?token=${token}&user=${existingUser}`);
    } catch (error) {
        console.error("Error in mobileRedirectHandler:", error);
        next(new AppError(500, "Mobile Redirect Failed"));
    }
};

// Handle logout by clearing token cookie
export const logoutHandler = (req, res, next) => {
    res.cookie("token", "loggedout", {
        maxAge: 0,
        sameSite: "lax",
        secure: false,
        expires: new Date(Date.now()),
        httpOnly: true,
    });
    res.redirect(process.env.CLIENT_URL);
};
