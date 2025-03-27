import { Queue, Worker } from 'bullmq';
import { sendNotification } from '../modules/notif/notification_controller.js';
import EventModel from '../modules/event/eventModel.js';

import User from '../modules/user/user.model.js';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();

console.log(`REDIS_PORT: ${process.env.REDIS_PORT}`);
console.log(`Type of REDIS_PORT: ${typeof process.env.REDIS_PORT}`);

// Redis configuration
const redisOptions = {
  host: process.env.REDIS_HOST,
  port: parseInt(process.env.REDIS_PORT), // Port needs to be an integer
  password: process.env.REDIS_PASSWORD,
};

// Check if the port is parsed correctly
console.log(`Parsed Redis Port: ${redisOptions.port}`);

// Create a new queue for reminders
export const reminderQueue = new Queue('reminderQueue', {
  connection: redisOptions,
});

// Worker to process the reminder queue
const reminderWorker = new Worker(
  'reminderQueue',
  async (job) => {
    const { userId, eventId } = job.data;

    // Find user and event
    const user = await User.findById(userId);
    const event = await EventModel.findById(eventId);

    if (user && event) {
      const data = {
        title: `Reminder: ${event.title}`,
        body: `Your event "${event.title}" starts at ${new Date(event.dateTime).toLocaleString()}`
      };

      // Send notification
      await sendNotification(user.fcmToken, data);
      console.log(`✅ Notification sent to ${user.name}`);
    }
  },
  {
    connection: redisOptions,
  }
);

reminderWorker.on('completed', (job) => {
  console.log(`🎉 Job ${job.id} completed successfully`);
});

reminderWorker.on('failed', (job, err) => {
  console.error(`❌ Job ${job.id} failed with error: ${err.message}`);
});
