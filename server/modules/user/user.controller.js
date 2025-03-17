import User from "./user.model.js";
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