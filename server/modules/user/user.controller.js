import User from "./user.model.js";
import { updateUserData } from "./user.model.js";
export const getUser = async (req, res, next) => {
    return res.json(req.user);
};


//not used
export const createUser = async (req, res) => {
    const data = req.body;
    const user = new User(data);
    const savedUser = await user.save();
    res.json(savedUser);
};
export const updateUserController = async (req, res) => {
    const email = req.body.email; // Extract email from the request body
    const userData = req.body;

    try {
        const updatedUser = await updateUserData(email, userData);

        if (!updatedUser) {
            return res.status(404).json({ message: "User not found" });
        }

        return res.status(200).json({
            message: "User updated successfully",
            user: updatedUser,
        });
    } catch (error) {
        console.error("Error updating user:", error);
        return res.status(500).json({ message: "Internal server error" });
    }
};
