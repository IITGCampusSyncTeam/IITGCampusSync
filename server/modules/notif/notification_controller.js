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



//set reminder by the user
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


