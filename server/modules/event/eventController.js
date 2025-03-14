import Event from './eventModel.js';
import User from '../user/user.model.js';
import {admin} from '../firebase/firebase_controller.js';

//  Function to create an event
async function createEvent(req, res) {
  try {
    const { title, description, dateTime, club, createdBy } = req.body;

    //  Fetch all users who have an FCM token
    const users = await User.find({ fcmToken: { $exists: true, $ne: null } });

    console.log(" Fetched Users with FCM Tokens:", users);

    //  Extract user IDs for participants and FCM tokens separately
    const participants = users.map(user => user._id);  // Store only ObjectIds
    const fcmTokens = users.map(user => user.fcmToken); // Store FCM tokens separately

    console.log("✅ Processed Participants (ObjectIds):", participants);
    console.log("✅ FCM Tokens for Notifications:", fcmTokens);

    // Save event in MongoDB
    const newEvent = await Event.create({
      title,
      description,
      dateTime,
      club,
      createdBy,
      participants, // Now stores only ObjectIds
      notifications: [],
    });

    console.log(" Event Created Successfully:", newEvent);

    //  Send notifications only if participants exist
    if (fcmTokens.length > 0) {
      for (const token of fcmTokens) {
        const message = {
          notification: {
            title: title,
            body: description,
          },
          token: token,
        };

        try {
          const response = await admin.messaging().send(message);
          console.log("✅ Notification sent successfully:", response);
        } catch (error) {
          console.error("❌ Error sending notification:", error);
        }
      }
    } else {
      console.log("⚠️ No FCM tokens found, skipping notifications.");
    }

    res.status(201).json({ status: "success", event: newEvent });
  } catch (error) {
    console.error("❌ Error creating event:", error);
    res.status(500).json({ status: "error", message: "Internal Server Error" });
  }
}

//  Function to fetch events
const getEvents = async (req, res) => {
  try {
    const events = await Event.find().populate('participants'); // Populating for debugging
    console.log(" Retrieved Events:", events);
    res.status(200).json(events);
  } catch (error) {
    console.error("❌ Error fetching events:", error);
    res.status(500).json({ message: "Failed to fetch events" });
  }
};

//  Export functions properly
export default { createEvent, getEvents };


//import Event from './eventModel.js'; // Adjust the path as necessary
//import admin from 'firebase-admin';  // ⬅️ Commented out Firebase import
//
//// Function to create an event (without Firebase notifications)
//const createEvent = async (req, res) => {
//  const { title, description, dateTime, club, createdBy, participants } = req.body;
//
//  if (!title || !description) {
//    return res.status(400).send('Missing required fields: title, description');
//  }
//
//  try {
//    // Create event logic
//    const event = new Event(req.body);
//    await event.save();
//    console.log('Event saved successfully:', event);
//
//
//    // Firebase Notification Logic (Commented Out)
//    const fcmTokens = [
//      "cEj62xj9RGiGdX-tL75T1u:APA91bHYs4cYvOEiaqI27hoWd2etFszhsQN_IV6rJgUylPXjME2FnY04bLgxY9qFjkKTl9sUFdacHH-thH422CcRMRhSywq7uTAYv7M34CrQm_RKpR5_QOI"
//    ];
//
//    const tokenChunks = chunkArray(fcmTokens, 500);
//
//    let successCount = 0;
//    let failureCount = 0;
//
//    for (const token of fcmTokens) {
//      const message = {
//        notification: {
//          title: title,
//          body: description,
//        },
//        token: token,
//      };
//      try {
//        const response = await admin.messaging().send(message);
//
//        console.log(`${response.successCount} messages were sent successfully`);
//
//        successCount += response.successCount;
//        failureCount += response.failureCount;
//
//        if (response.failureCount > 0) {
//          const failedTokens = [];
//          response.responses.forEach((resp, idx) => {
//            if (!resp.success) {
//              failedTokens.push(chunk[idx]);
//              console.error('Notification failed to send to:', chunk[idx]);
//              console.error('Error:', resp.error);
//            }
//          });
//
//          console.log('Failed tokens:', failedTokens);
//        }
//      } catch (error) {
//        console.error('Error sending notifications to chunk:', error);
//        failureCount += chunk.length;
//      }
//    }
//
//
//    res.status(201).json({
//      message: 'Event created successfully',
//      event
//    });
//  } catch (err) {
//    console.error('Error creating event:', err);
//    res.status(500).json({ error: 'Error creating event' });
//  }
//};
//
//// Function to fetch events
//const getEvents = async (req, res) => {
//  try {
//    const events = await Event.find();
//    res.status(200).json(events);
//  } catch (error) {
//    console.error('Error fetching events:', error);
//    res.status(500).json({ message: 'Failed to fetch events' });
//  }
//};
//
//// Helper function to split array into chunks
//function chunkArray(array, chunkSize) {
//  const chunks = [];
//  for (let i = 0; i < array.length; i += chunkSize) {
//    chunks.push(array.slice(i, i + chunkSize));
//  }
//  return chunks;
//}
//
//export default {
//  createEvent,
//  getEvents,
//};
