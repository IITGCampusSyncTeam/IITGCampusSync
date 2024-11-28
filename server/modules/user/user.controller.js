import User from "./user.model.js";
//import { updateUserController } from "./user.model.js";
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
    const { email } = req.params;

    try {
        const updatedUser = await User.findOneAndUpdate({ 'email': email }, req.body, { new: true });
        if (!updatedUser) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(updatedUser);
    } catch (err) {
        console.log(err);
        res.status(500).json({ message: 'Error updating user' });
    }
};
