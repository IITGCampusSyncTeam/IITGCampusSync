import User from "./user.model.js";
import Tag from "../tag/tagModel.js";
import Club from "../club/clubModel.js";
import Event from "../event/eventModel.js";

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
// Select a tag (add a tag to user profile)
export const selectTag = async (req, res) => {
    try {
        const { email, tagId } = req.params; // Get user email & tagId from route params

        // Find user by email
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        // Check if tag exists
        const tag = await Tag.findById(tagId);
        if (!tag) {
            return res.status(404).json({ message: "Tag not found" });
        }

        // Add tag to user's list (prevent duplicates)
        user.tag.addToSet(tagId); 
        await user.save();

        // Add user to tag's `users` list (bi-directional linking)
        tag.users.addToSet(user._id);
        await tag.save();

        // Populate tags before sending response
        await user.populate("tag");

        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: "Error adding tag", error: error.message });
    }
};




// ✅ Delete a tag from user's profile
export const deleteUserTag = async (req, res) => {
    try {
        const { email, tagId } = req.params; // Get user email & tagId from route params

        // Find user by email
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        // Check if tag exists in the user's list
        if (!user.tag.includes(tagId)) {
            return res.status(400).json({ message: "Tag not found in user's profile" });
        }

        // Remove the tag from user's tag list
        user.tag.pull(tagId);
        await user.save();

        // Find the tag and remove the user from its `users` list
        const tag = await Tag.findById(tagId);
        if (tag) {
            tag.users.pull(user._id);
            await tag.save();
        }

        // Populate tags before sending response
        await user.populate("tag");

        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: "Error removing tag", error: error.message });
    }
};


export const getUserFollowedEvents = async (req, res) => {
    try {
        const userId = req.user._id; // Extract user ID from the request

        // Find the user and populate their subscribed clubs
        const user = await User.findById(userId).populate("subscribedClubs");
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        const clubIds = user.subscribedClubs.map(club => club._id);

        // Find upcoming events for the clubs the user is following
        const currentDateTime = new Date();
        const upcomingEvents = await Event.find({
            club: { $in: clubIds },
            dateTime: { $gt: currentDateTime }
        }).sort({ dateTime: 1 })
        .populate("club", "name"); // Populate club name

        res.status(200).json({ status: "success", events: upcomingEvents });
    } catch (error) {
        console.error("Error fetching upcoming events for user:", error);
        res.status(500).json({ message: "Failed to fetch upcoming events" });
    }
};

//export default getUserFollowedEvents;