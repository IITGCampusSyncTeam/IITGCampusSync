import { model, Schema } from "mongoose";
import Joi from "joi";
import axios from "axios";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config(); // Load environment variables

const userSchema = Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    rollNumber: { type: Number, required: true, unique: true },
    semester: { type: Number, required: true },
    degree: { type: String, required: true },
    department: { type: String, required: true },
});

// Generating JWT
userSchema.methods.generateJWT = function () {
    const user = this;
    const token = jwt.sign({ user: user._id }, process.env.JWT_SECRET, {
        expiresIn: "24d",
    });
    return token;
};

// Finding user by JWT
userSchema.statics.findByJWT = async function (token) {
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const userId = decoded.user;
        const user = await this.findOne({ _id: userId });
        if (!user) return false;
        return user;
    } catch (error) {
        return false;
    }
};

const User = model("User", userSchema);
export default User;

export const validateUser = function (obj) {
    const joiSchema = Joi.object({
        name: Joi.string().min(4).required(),
        email: Joi.string().email().required(),
        rollNumber: Joi.number().required(),
        semester: Joi.number().required(),
        degree: Joi.string().required(),
        department: Joi.string().required(),
    });
    return joiSchema.validate(obj);
};

export const updateUserData = async (userId, userData) => {
    const user = await User.findOne({ _id: userId });
    if (!user) return false;

    if (userData.newUserData.newUserName) {
        user.name = userData.newUserData.newUserName;
    } else if (userData.newUserData.newUserSem) {
        user.semester = userData.newUserData.newUserSem;
    }
    await user.save();
    return user;
};

export const getUserFromToken = async function (access_token) {
    try {
        const config = {
            method: "get",
            url: "https://graph.microsoft.com/v1.0/me",
            headers: {
                Authorization: `Bearer ${access_token}`,
            },
        };
        const response = await axios.get(config.url, {
            headers: config.headers,
        });
        return response;
    } catch (error) {
        return false;
    }
};

export const findUserWithEmail = async function (email) {
    const user = await User.findOne({ email: email });
    console.log("found user with email", user);
    if (!user) return false;
    return user;
};
