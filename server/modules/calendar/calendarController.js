import EventModel from '../event/eventModel.js';

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

// Export CalendarController as a default export
export default {
    getUserEvents,
    setPersonalReminderTime
};