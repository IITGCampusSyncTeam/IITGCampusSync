import EventModel from "../event/eventModel.js";
import User from "../user/user.model.js";
import { getGoogleAuthURL, getTokensFromCode, createGoogleEvent } from "../calendar/googleCalendarService.js";

const getUserEvents = async (req, res) => {
    const outlookId = req.params.outlookId;
    const date = req.params.date;
    try {
        const startOfDay = new Date(date);
        const endOfDay = new Date(date);
        endOfDay.setHours(23, 59, 59, 999);
        const events = await EventModel.find({
            outlookId,
            startTime: { $gte: startOfDay, $lt: endOfDay }
        });
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ "Message": error.message });
    }
};

const setPersonalReminderTime = async (req, res) => {
    const outlookId = req.params.outlookId;
    const { eventId, reminderTime } = req.body;

    try {
        const event = await EventModel.findOneAndUpdate(
            { _id: eventId, outlookId: outlookId },
            { reminderTime: reminderTime },
            { new: true }
        );

        if (!event) {
            throw new Error('Event not found');
        }
        res.status(200).json({ message: 'Reminder time set successfully' });
    } catch (error) {
        res.status(500).json({ "Message": error.message });
    }
};

// Get OAuth URL for frontend
export const getGoogleOAuthURLController = (req, res) => {
  try {
    const userId = req.query.userId;
    if (!userId) throw new Error("User ID is required");

    const url = getGoogleAuthURL(userId);
    res.status(200).json({ url });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
// Save tokens after OAuth
export const saveGoogleTokensController = async (req, res) => {
  try {
    const { code, state } = req.query; // state contains userId
    const userId = state;
    if (!userId) throw new Error("User ID is missing");
    if (!code) throw new Error("Authorization code is missing");

    const { access_token, refresh_token, expiry_date } = await getTokensFromCode(code);

    const user = await User.findById(userId);
    if (!user) throw new Error("User not found");

    user.googleAccessToken = access_token;
    user.googleRefreshToken = refresh_token;
    user.googleTokenExpiry = new Date(expiry_date);
    await user.save();

    res.status(200).json({ message: "Google Calendar linked successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


//Link event to Google Calendar
//Fetches app event by event id and adds it to user's Google Calendar
export const linkEventToGoogleController = async (req, res) => {
  try {
    const { eventId, userId } = req.params;

    if (!userId) throw new Error("User ID is required");
    if (!eventId) throw new Error("Event ID is required");

    const event = await EventModel.findById(eventId);
    if (!event) throw new Error("Event not found");

    const googleEvent = await createGoogleEvent(userId, event);
    res.status(200).json({ message: "Event added to Google Calendar", googleEvent });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

export default {
    getGoogleOAuthURLController,
    saveGoogleTokensController,
    linkEventToGoogleController,
    getUserEvents,
    setPersonalReminderTime
};