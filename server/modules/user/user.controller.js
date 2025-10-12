import User from "./user.model.js";
import Tag from "../tag/tagModel.js";
import Club from "../club/clubModel.js";
import Event from "../event/eventModel.js";

export const getUser = async (req, res, next) => {
    return res.json(req.user);
};

export const getUserWithEmail = async (req, res) => {
    const { email } = req.params;
    try {
        console.log("Fetching user from database...");
        const user = await User.findOne({ email }).lean()
        if (!user) {
            console.log("User not found.");
            return res.status(404).json({ message: 'Club not found' });
        }
        console.log("user fetched:", user);
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
        console.log("Final user data before sending:", JSON.stringify(user, null, 2));
        res.status(200).json(user);
    } catch (err) {
        console.error("Error fetching user details:", err);
        res.status(500).json({ message: 'Error fetching user details', error: err });
    }
};

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

export const getUserFollowedEvents = async (req, res) => {
    try {
        const userId = req.user._id;
        const user = await User.findById(userId).populate("subscribedClubs");
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        const clubIds = user.subscribedClubs.map(club => club._id);
        const currentDateTime = new Date();
        const upcomingEvents = await Event.find({
            club: { $in: clubIds },
            dateTime: { $gt: currentDateTime }
        }).sort({ dateTime: 1 })
            .populate("club", "name");
        res.status(200).json({ status: "success", events: upcomingEvents });
    } catch (error) {
        console.error("Error fetching upcoming events for user:", error);
        res.status(500).json({ message: "Failed to fetch upcoming events" });
    }
};

export const selectTags = async (req, res) => {
    try {
        const { email } = req.params;
        const { tagIds } = req.body;

        if (!tagIds || !Array.isArray(tagIds)) {
            return res.status(400).json({ message: "Please provide an array of tag IDs." });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        user.tag.addToSet(...tagIds);
        await user.save();

        await Tag.updateMany(
            { _id: { $in: tagIds } },
            { $addToSet: { users: user._id } }
        );

        await user.populate("tag");
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: "Error adding tags to user", error: error.message });
    }
};

export const deleteUserTags = async (req, res) => {
    try {
        const { email } = req.params;
        const { tagIds } = req.body;

        if (!tagIds || !Array.isArray(tagIds)) {
            return res.status(400).json({ message: "Please provide an array of tag IDs." });
        }

        const updatedUser = await User.findOneAndUpdate(
            { email },
            { $pull: { tag: { $in: tagIds } } },
            { new: true }
        );

        if (!updatedUser) {
            return res.status(404).json({ message: "User not found" });
        }

        await Tag.updateMany(
            { _id: { $in: tagIds } },
            { $pull: { users: updatedUser._id } }
        );

        await updatedUser.populate("tag");
        res.status(200).json(updatedUser);
    } catch (error) {
        res.status(500).json({ message: "Error removing tags from user", error: error.message });
    }
};