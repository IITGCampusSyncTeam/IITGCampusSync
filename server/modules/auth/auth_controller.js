import axios from "axios";
import qs from "querystring";
import AppError from "../../utils/appError.js";
import catchAsync from "../../utils/catchAsync.js";


const clientid = process.env.CLIENT_ID;
const clientSecret = process.env.CLIENT_VALUE;
const redirect_uri = process.env.REDIRECT_URI;

import { findUserWithEmail, getUserFromToken, validateUser } from "../user/user.model.js";

import User from "../user/user.model.js";

//not used
export const loginHandler = (req, res) => {
    res.redirect(
        'https://login.microsoftonline.com/850aa78d-94e1-4bc6-9cf3-8c11b530701c/oauth2/v2.0/authorize?client_id=${clientid}&response_type=code&redirect_uri=${redirect_uri}&scope=offline_access%20user.read&state=12345'
        //use my endpoint
    );
};
export const guestLoginHanlder = async (req, res, next) => {
    const guest = await User.findOne({ email: "guest@coursehubiitg.in" });
    if (!guest) return next(new AppError(500, "Something went wrong."));
    const token = guest.generateJWT();
    res.json({ token });
};

const getDepartment = async (access_token) => {
    var config = {
        method: "get",
        url: "https://graph.microsoft.com/beta/me/profile",
        headers: {
            Authorization: `Bearer ${access_token}`,
            "Content-Type": "application/x-www-form-urlencoded",
            Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
            Host: "graph.microsoft.com",
        },
    };
    const response = await axios.get(config.url, {
        headers: config.headers,
    });
    return response.data.positions[0].detail.company.department;
};

function calculateSemester(rollNumber) {
    const year = parseInt(rollNumber.slice(0, 2));
    const semester = academicdata.semesterMap[year];
    return semester;
}

export const redirectHandler = async (req, res, next) => {
    const { code } = req.query;
  console.log("flag")
    var data = qs.stringify({
        client_secret: clientSecret,
        client_id: clientid,
        //redirect_uri: redirect_uri,
        redirect_uri: "http://localhost:8080/api/auth/login/redirect",
        scope: "user.read",
        grant_type: "authorization_code",
        code: code,
    });

    console.log(data);

    var config = {
        method: "post",
        url: `https://login.microsoftonline.com/850aa78d-94e1-4bc6-9cf3-8c11b530701c/oauth2/v2.0/token`,
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            client_secret: clientSecret,
        },
        data: data,
    };
    const response = await axios.post(config.url, config.data, {
        headers: config.headers,
    });

    if (!response.data) throw new AppError(500, "Something went wrong");

    console.log(response.data);

    const AccessToken = response.data.access_token;
    const RefreshToken = response.data.refresh_token;

    const userFromToken = await getUserFromToken(AccessToken);

    if (!userFromToken || !userFromToken.data) throw new AppError(401, "Access Denied");

    const roll = userFromToken.data.surname;
    if (!roll) throw new AppError(401, "Sign in using Institute Account");

    let existingUser = await findUserWithEmail(userFromToken.data.mail); //find with email

    if (!existingUser) {
        const courses = await fetchCourses(userFromToken.data.surname);
        const department = await getDepartment(AccessToken);

        const userData = {
            name: userFromToken.data.displayName,
            degree: userFromToken.data.jobTitle,
            rollNumber: userFromToken.data.surname,
            email: userFromToken.data.mail,
            // branch: department, //calculate branch
            semester: calculateSemester(userFromToken.data.surname), //calculate sem
            courses: courses,
            department: department,
        };

        const { error } = validateUser(userData);
        if (error) throw new AppError(500, error.message);

        const user = new User(userData);
        existingUser = await user.save();
    }

    const token = existingUser.generateJWT();

    res.cookie("token", token, {
        maxAge: 2073600000,
        sameSite: "lax",
        secure: false,
        expires: new Date(Date.now() + 2073600000),
        httpOnly: true,
    });

    return res.redirect(appConfig.clientURL);
};

export const mobileRedirectHandler = async (req, res, next) => {
    const { code } = req.query;
    console.log("flag")
    var data = qs.stringify({
        client_secret: 'yg48Q~GGKqo~Do7US0gLN7VJWK9gr0UqwriAKbv~',
        client_id: '7e8cd638-96e9-4441-b3a5-dd3ea895a46d',
        //redirect_uri: redirect_uri,
        redirect_uri: "http://localhost:3000/api/auth/login/redirect/mobile",
        scope: "user.read",
        grant_type: "authorization_code",
        code: code,
    });

    var config = {
        method: "post",
        url: 'https://login.microsoftonline.com/850aa78d-94e1-4bc6-9cf3-8c11b530701c/oauth2/v2.0/token',
        headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            client_secret: 'yg48Q~GGKqo~Do7US0gLN7VJWK9gr0UqwriAKbv~',
        },
        data: data,
    };
    const response = await axios.post(config.url, config.data, {
        headers: config.headers,
    });

 if (!response.data) throw new AppError(500, "Something went wrong");

    const AccessToken = response.data.access_token;
    //const RefreshToken = response.data.refresh_token;

    const userFromToken = await getUserFromToken(AccessToken);

    if (!userFromToken || !userFromToken.data) throw new AppError(401, "Access Denied");

    const roll = userFromToken.data.surname;
    if (!roll) throw new AppError(401, "Sign in using Institute Account");

    let existingUser = await findUserWithEmail(userFromToken.data.mail); //find with email

    if (!existingUser) {
       
        const department = await getDepartment(AccessToken);

        const userData = {
            name: userFromToken.data.displayName,
            degree: userFromToken.data.jobTitle,
            rollNumber: userFromToken.data.surname,
            email: userFromToken.data.mail,
            // branch: department, //calculate branch
            semester: calculateSemester(userFromToken.data.surname),
            department: department,
        };

        const { error } = validateUser(userData);
        if (error) throw new AppError(500, error.message);

        const user = new User(userData);
        existingUser = await user.save();
    }

    const token = existingUser.generateJWT();

    //     const encryptedToken = EncryptText(token);

    return res.redirect('iitgsync://success?token=${token}');
};

export const logoutHandler = (req, res, next) => {
    //     res.clearCookie("token");
    res.cookie("token", "loggedout", {
        maxAge: 0,
        sameSite: "lax",
        secure: false,
        expires: new Date(Date.now()),
        httpOnly: true,
    });
    res.redirect(appConfig.clientURL);
};