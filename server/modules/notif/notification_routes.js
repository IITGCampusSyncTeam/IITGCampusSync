import express from 'express';
import { setReminder ,setReminderForFollowers } from './notification_controller.js';

const router = express.Router();

// Route to set reminder
router.post('/set-reminder', setReminder);
router.post('/set-rem-for-followers',setReminderForFollowers);

//// Route to manually trigger checking reminders
//router.get('/check-reminders', async (req, res) => {
//    try {
//        await checkRemindersAndSendNotifications();
//        res.status(200).json({ message: 'Reminders checked successfully!' });
//    } catch (error) {
//        console.error('Error checking reminders:', error);
//        res.status(500).json({ error: 'Internal server error' });
//    }
//});


export default router;