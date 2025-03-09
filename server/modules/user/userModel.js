import { model, Schema } from "mongoose";
import Joi from "joi";
import axios from "axios";
import jwt from "jsonwebtoken";
import config from "../../config/default.js";
import { logger } from "@azure/identity";
import mongoose from 'mongoose';

const reminderSchema = new Schema({
    /*notificationId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Notification',
        required: true,
    },*/
    reminderTime: {
        type: Date,
        required: true,
    },
});

const userSchema = Schema({
    name: { type: String, required: true },
    outlookID: { type: String, required: true, unique: true },
    role:{ type:String, enum: ['normal', 'club head', 'higher authority'], default: 'normal', required: true},
    profilePicture: {
        type: String,
        validate: {
            validator: function(v) {
                // Simple URL validation regex
                return /^(ftp|http|https):\/\/[^ "]+$/.test(v);
            },
            message: props => `${props.value} is not a valid URL!`,
        },
    },
    /*subscribedClubs: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Club',
    }],
    clubsResponsible: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Club',
    }],*/
    reminders: [reminderSchema],
    dept: {
        type: String,
        required: true,
        trim: true,
    },
    year: {
        type: Number,
        required: true,
        min: 1, // Assuming year starts at 1
        max: 8, // Assuming a maximum of 8 years
    },
    degree: {
        type: String,
        required: true,
        trim: true,
    },
}, {
    timestamps: true, // Automatically adds createdAt and updatedAt fields
})
userSchema.methods.generateJWT = function () {
    var user = this;
    var token = jwt.sign({ user: user._id }, config.jwtSecret, {
        expiresIn: "24d",
    });
    return token;
};

userSchema.statics.findByJWT = async function (token) {
    try {
        var user = this;
        var decoded = jwt.verify(token, config.jwtSecret);
        const id = decoded.user;
        const fetchedUser = user.findOne({ _id: id });
        if (!fetchedUser) return false;
        return fetchedUser;
    } catch (error) {
        return false;
    }
};

const User = mongoose.model('user', userSchema);
module.exports = User;
/*const User = mongoose.model('User', userSchema);

module.exports = User;*/ 

export const validateUser = function (obj) {
    const joiSchema = Joi.object({
        name: Joi.string().min(4).required(),
        email: Joi.string().email().required(),
        rollNumber: Joi.number().required(),
        // branch: Joi.string().required(),
        semester: Joi.number().required(),
        degree: Joi.string().required(),
        courses: Joi.array().required(),
        department: Joi.string().required(),
    });
    return joiSchema.validate(obj);
};
export const updateUserData = async (userId, userData) => {
    User.findOne({ _id: userId }, async (err, doc) => {
        if (err) {
            logger.info("ERROR IN UPDATING USER");
        }
        if (userData.newUserData.newUserName) {
            doc.name = userData.newUserData.newUserName;
            await doc.save();
        } else if (userData.newUserData.newUserSem) {
            doc.semester = userData.newUserData.newUserSem;
            await doc.save();
        }
    });
};

export const getUserFromToken = async function (access_token) {
    try {
        var config = {
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

// export const findUserWithRollNumber = async function (rollNumber) {
// 	const user = await User.findOne({ rollNumber: rollNumber });
// 	if (!user) return false;
// 	return user;
// };

/*export const findUserWithEmail = async function (email) {
    const user = await User.findOne({ email: email });
    // console.log("found user with email", user);
    if (!user) return false;
    return user;
};*/


    