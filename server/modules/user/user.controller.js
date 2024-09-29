import { User} from "./user.model.js";
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
    const data = req.body;
    updateUserData(req.user._id, data);
};
