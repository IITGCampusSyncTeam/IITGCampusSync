
import { Queue, Worker } from 'bullmq';
import { sendNotification } from '../modules/notif/notification_controller.js';
import EventModel from '../modules/event/eventModel.js';
import Club from '../modules/club/clubModel.js';
import User from '../modules/user/user.model.js';
import dotenv from 'dotenv';

dotenv.config();

const redisOptions = {
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT, 10) || 6379,
  password: process.env.REDIS_PASSWORD || '',
};

// Reminder Queue
export const reminderQueue = new Queue('reminderQueue', {
  connection: redisOptions,
});

// Worker for processing reminder jobs
const reminderWorker = new Worker(
  'reminderQueue',
  async (job) => {
    const { name, data } = job;

    if (name === 'sendReminder') {
      const { userId, eventId } = data;
      const user = await User.findById(userId);
      const event = await EventModel.findById(eventId);
      if (user && event) {
        await sendNotification(user.fcmToken, {
          title: `Reminder: ${event.title}`,
          body: `Your event "${event.title}" starts at ${new Date(event.dateTime).toLocaleString()}`
        });
        console.log(`✅ Reminder sent to ${user.name}`);
      }
    }

    if (name === 'sendClubReminder') {
      const { eventId } = data;
      const event = await EventModel.findById(eventId).populate('club');
      const club = event.club;

      if (!club) throw new Error('Club not found for this event');

      const populatedClub = await ClubModel.findById(club._id).populate('followers');

      for (const follower of populatedClub.followers) {
        if (follower.fcmToken) {
          await sendNotification(follower.fcmToken, {
            title: `⏰ Reminder from ${club.name}`,
            body: `The event "${event.title}" starts at ${new Date(event.dateTime).toLocaleString()}`
          });
          console.log(`🔔 Sent to follower ${follower.name}`);
        }
      }
    }
  },
  {
    connection: redisOptions,
  }
);

// Worker Events
reminderWorker.on('completed', (job) => {
  console.log(`🎉 Job ${job.id} completed`);
});

reminderWorker.on('failed', (job, err) => {
  console.error(`❌ Job ${job.id} failed: ${err.message}`);
});
