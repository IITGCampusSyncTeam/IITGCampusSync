import { model, Schema, Types } from "mongoose";
import Joi from "joi";
import axios from "axios";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config(); // Load environment variables

const userSchema = new Schema({
    name: { type: String, required: true },
    fcmToken: {type: String, required:false}, //change it to true later on
    email: { type: String, required: true, unique: true },
    isClub: { type: Boolean, default: false },
    rollNumber: { type: Number, required: true, unique: true },
    semester: { type: Number, required: true },
    hostel: {type:String},
    roomnum:{type:String},
    contact:{type:String},
    degree: { type: String, required: true },
    department: { type: String, required: true },
    role: { type: String, enum: ['normal', 'club_head', 'higher_authority'], default: 'normal' },
    refreshToken: {
        type: String,
        select: false, // prevents it from being sent in queries unless explicitly selected
    },
    profilePicture: {
        type: String,
        validate: {
            validator: function(v) {
                return /^(http|https):\/\/[^ "]+$/.test(v); // Basic URL validation
            },
            message: props => `${props.value} is not a valid URL!`
        }
    },
    subscribedClubs: [
        {
            type: Types.ObjectId,
            ref: 'Club'
        }
    ],
    clubsResponsible: [
        {
            type: Types.ObjectId,
            ref: 'Club'
        }
    ],
    reminders: [
        {
            notificationId: {
                type: Types.ObjectId,
                ref: 'Notification'
            },
            reminderTime: {
                type: Date
            }
        }
    ],
    merchOrders: [
        {
            type: Types.ObjectId,
            ref: 'Order' // Reference to orders made by the user
        }
    ],
    tag: [
        {
            type: Types.ObjectId,
            ref: 'Tag'
        }
    ]
});

// Generating JWT
userSchema.methods.generateJWT = function () {
    const token = jwt.sign({ user: this._id }, process.env.JWT_SECRET, {
        expiresIn: "24d",
    });
    return token;
};

// Finding user by JWT
userSchema.statics.findByJWT = async function (token) {
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await this.findById(decoded.user);
        return user || false;
    } catch (error) {
        return false;
    }
};

const User = model("User", userSchema);
export default User;

// Joi validation schema for user input
export const validateUser = function (obj) {
    const joiSchema = Joi.object({
        name: Joi.string().min(4).required(),
        email: Joi.string().email().required(),
        isClub: Joi.boolean(),
        rollNumber: Joi.number().required(),
        semester: Joi.number().required(),
        hostel: Joi.string(),
        roomnum: Joi.string(),
        contact: Joi.string(),
        degree: Joi.string().required(),
        department: Joi.string().required(),
        role: Joi.string().valid('normal', 'club_head', 'higher_authority').default('normal'),
        profilePicture: Joi.string().uri().optional(),
        subscribedClubs: Joi.array().items(Joi.string().regex(/^[0-9a-fA-F]{24}$/)), // ObjectId format
        clubsResponsible: Joi.array().items(Joi.string().regex(/^[0-9a-fA-F]{24}$/)), // ObjectId format
        reminders: Joi.array().items(
            Joi.object({
                notificationId: Joi.string().regex(/^[0-9a-fA-F]{24}$/), // ObjectId format
                reminderTime: Joi.date()
            })
        )
    });

    return joiSchema.validate(obj);
};




// Retrieve user from Microsoft Graph API with access token
export const getUserFromToken = async function (access_token) {
    try {
        const response = await axios.get("https://graph.microsoft.com/v1.0/me", {
            headers: {
                Authorization: `Bearer ${access_token}`,
            }
        });
        return response;
    } catch (error) {
        return false;
    }
};

// Find user by email
export const findUserWithEmail = async function (email) {
    const user = await User.findOne({ email });
    console.log("found user with email", user);
    return user || false;
};
