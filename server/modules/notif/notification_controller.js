import admin from 'firebase-admin';
import User from '../user/user.model.js';
import EventModel from '../event/eventModel.js';
import mongoose from 'mongoose';
import { reminderQueue } from '../../config/bullConfig.js';
import Club from '../club/clubModel.js';

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

//organizer can set reminders
export const setReminderForFollowers = async (req, res) => {
  try {
    const { eventId, hoursBefore } = req.body;

    if (!eventId || !hoursBefore) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Fetch the event with club populated
    const event = await EventModel.findById(eventId).populate('club');
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }

    const club = event.club;
    if (!club || !club.followers || club.followers.length === 0) {
      return res.status(404).json({ error: 'No followers found for this club' });
    }

    const eventDateTime = new Date(event.dateTime);
    const reminderTime = new Date(eventDateTime.getTime() - hoursBefore * 60 * 60 * 1000);
    const delay = reminderTime.getTime() - Date.now();

    if (delay > 0) {
      await reminderQueue.add(
        'sendReminderToFollowers',
        {
          eventId,
          followerIds: Club.followers,
        },
        { delay }
      );

      console.log(`📅 Reminder scheduled for ${club.followers.length} followers of club ${club._id}`);
    } else {
      return res.status(400).json({ error: 'Reminder time is in the past' });
    }

    res.status(200).json({ message: 'Reminder scheduled for all followers successfully!' });
  } catch (error) {
    console.error('Error setting reminders:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

