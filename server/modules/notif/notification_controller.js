import admin from 'firebase-admin';
import User from '../user/user.model.js';
import EventModel from '../event/eventModel.js';
import mongoose from 'mongoose';
import { reminderQueue } from '../../config/bullConfig.js';


export const sendNotification = async (token, data) => {
    const message = {
        token: token,
        notification: {
            title: data.title,
            body: data.body
        },

    };

    try {
        await admin.messaging().send(message);
        console.log('Notification sent successfully');
    } catch (error) {
        console.error('Error sending notification:', error);
    }
};




export const setReminder = async (req, res) => {
  try {
    const { userId, eventId, hoursBefore } = req.body;

    if (!userId || !eventId || !hoursBefore) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Validate event existence
    const event = await EventModel.findById(eventId);
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }

    // Calculate reminder time based on event dateTime
    const eventDateTime = new Date(event.dateTime);
    const reminderTime = new Date(eventDateTime.getTime() - hoursBefore * 60 * 60 * 1000);

    // Add job to BullMQ queue
    const delay = reminderTime.getTime() - Date.now(); // Time left before reminder
    if (delay > 0) {
      await reminderQueue.add(
        'sendReminder',
        { userId, eventId },
        { delay }
      );
      console.log(`⏰ Reminder set for user ${userId} for event ${eventId}`);
    }

    res.status(200).json({ message: 'Reminder scheduled successfully!' });
  } catch (error) {
    console.error('Error setting reminder:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};


export const checkRemindersAndSendNotifications = async () => {
    try {
        const now = new Date(); // Get current UTC time
        const windowEnd = new Date(now.getTime() + 5 * 60 * 1000); // 5-minute buffer

        console.log(`⏰ Checking reminders at: ${now}`);

        // Find users with reminders that are due within the 5-minute window
        const users = await User.find({
            'reminders.reminderTime': {
                $gte: now, // Greater than or equal to current time
                $lte: windowEnd // Less than or equal to 5 minutes from now
            }
        });

        console.log(`🔎 Found ${users.length} users with due reminders`);

        for (const user of users) {
            for (const reminder of user.reminders) {
                const reminderTimeUTC = new Date(reminder.reminderTime);

                // Check if the reminder is within the 5-minute window
                if (reminderTimeUTC >= now && reminderTimeUTC <= windowEnd) {
                    console.log(`✅ Sending reminder for user: ${user.name}`);
                    const event = await EventModel.findById(reminder.notificationId);

                    if (event) {
                        const data = {
                            title: `Reminder: ${event.title}`,
                            body: `Your event "${event.title}" starts at ${new Date(event.dateTime).toLocaleString()}`
                        };

                        // Send notification
                        await sendNotification(user.fcmToken, data);
                    }
                }
            }

            // Remove sent reminders after notification is sent
            user.reminders = user.reminders.filter(reminder => new Date(reminder.reminderTime) > windowEnd);
            await user.save();
        }
    } catch (error) {
        console.error('❌ Error checking reminders:', error);
    }
};
