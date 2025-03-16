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
const tenant_id = process.env.AZURE_TENANT_ID;

import { findUserWithEmail, getUserFromToken, validateUser } from "../user/user.model.js";
import User from "../user/user.model.js";
import Tag from "../tag/tagModel.js"; // Import Tag model for fetching tag names

// Fetch department information using Microsoft Graph API
const getDepartment = async (access_token) => {
    try {
        console.log("Fetching department information...");
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
        console.log("Department fetched successfully:", response.data.positions[0]?.detail?.company?.department);
        return response.data.positions[0]?.detail?.company?.department;
    } catch (error) {
        console.error("Error fetching department:", error);
        return null;
    }
};

// Calculate semester based on roll number and academic year mapping
function calculateSemester(rollNumber) {
    const year = parseInt(rollNumber.slice(0, 2));
    console.log("Calculating semester for roll number:", rollNumber, "=> Semester:", academicdata.semesterMap[year] || 1);
    return academicdata.semesterMap[year] || 1;
}

// Handle mobile redirect for authentication
export const mobileRedirectHandler = async (req, res, next) => {
    try {
        console.log("Mobile Redirect Handler Triggered");
        const { code } = req.query;
        if (!code) {
            console.error("No authorization code received.");
            throw new AppError(400, "No authorization code provided.");
        }

        console.log("Received authorization code:", code);

        const data = qs.stringify({
            client_secret: clientSecret,
            client_id: clientid,
            redirect_uri: redirect_uri,
            scope: "user.read",
            grant_type: "authorization_code",
            code: code,
        });

        const config = {
            method: "post",
            url: `https://login.microsoftonline.com/${tenant_id}/oauth2/v2.0/token`,
            headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                client_secret: clientSecret,
            },
            data: data,
        };

        console.log("Making request to Microsoft OAuth token endpoint...");
        const response = await axios.post(config.url, config.data, { headers: config.headers });

        if (!response.data) {
            console.error("OAuth token response is empty.");
            throw new AppError(500, "Something went wrong while fetching OAuth tokens.");
        }

        const accessToken = response.data.access_token;
        const RefreshToken = response.data.refresh_token;
        console.log("OAuth Tokens retrieved successfully. Refresh Token:", RefreshToken);

        console.log("Fetching user information from Microsoft Graph API...");
        const userFromToken = await getUserFromToken(accessToken);
        if (!userFromToken || !userFromToken.data) {
            console.error("User information could not be retrieved.");
            throw new AppError(401, "Access Denied: Unable to fetch user details.");
        }

        console.log("User details retrieved:", userFromToken.data);

        const rollNumber = userFromToken.data.surname;
        if (!rollNumber) {
            console.error("Roll number missing in user data.");
            throw new AppError(401, "Sign in using Institute Account");
        }

        console.log("Checking if user already exists in database...");
        let existingUser = await findUserWithEmail(userFromToken.data.mail);

        if (!existingUser) {
            console.log("User not found. Creating a new user...");
            const department = await getDepartment(accessToken);

            const userData = {
                name: userFromToken.data.displayName,
                email: userFromToken.data.mail,
                rollNumber: rollNumber,
                degree: userFromToken.data.jobTitle,
                semester: calculateSemester(rollNumber),
                department: department,
                role: "normal", // default role
            };

            console.log("Validating new user data...");
            const { error } = validateUser(userData);
            if (error) {
                console.error("User data validation failed:", error.message);
                throw new AppError(400, error.message);
            }

            console.log("Saving new user to database...");
            const newUser = new User(userData);
            existingUser = await newUser.save();
            console.log("New user created successfully:", existingUser);
        }

        console.log("Fetching user from database...");
        const user = await User.findById(existingUser._id).lean();
        console.log("User fetched:", user);

        if (!user.tag || user.tag.length === 0) {
            console.log("User has no associated tags.");
            user.tag = [];
        } else {
            console.log("Fetching tag names for user...");
            const userTags = await Tag.find({ _id: { $in: user.tag } })
                .select("_id title")
                .lean();
            console.log("Tags retrieved:", userTags);

            user.tag = userTags.map(tag => ({
                id: tag._id.toString(),
                name: tag.title,
            }));
        }

        console.log("Generating JWT token...");
        const token = existingUser.generateJWT();
        console.log("JWT token generated successfully.");

        console.log("Redirecting to mobile app with user data...");
        return res.redirect(
            `iitgsync://success?token=${token}&user=${encodeURIComponent(
                JSON.stringify(user)
            )}`
        );
    } catch (error) {
        console.error("Error in mobileRedirectHandler:", error);
        next(new AppError(500, "Mobile Redirect Failed"));
    }
};

// Handle logout by clearing token cookie
export const logoutHandler = (req, res, next) => {
    console.log("Logging out user...");
    res.cookie("token", "loggedout", {
        maxAge: 0,
        sameSite: "lax",
        secure: false,
        expires: new Date(Date.now()),
        httpOnly: true,
    });
    console.log("User logged out successfully.");
    res.redirect(process.env.CLIENT_URL);
};
