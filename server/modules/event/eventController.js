import Event from './eventModel.js';
import User from '../user/user.model.js';
import {admin} from '../firebase/firebase_controller.js';


 // Function to create an event
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
//TODO: if we r using for loop then will take lot of time, performance issue
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
//    console.log(" Retrieved Events:", events);
    res.status(200).json(events);
  } catch (error) {
    console.error("❌ Error fetching events:", error);
    res.status(500).json({ message: "Failed to fetch events" });
  }
};

// Function to get upcoming events
const getUpcomingEvents = async (req, res) => {
  try {
    const currentDateTime = new Date();

    // Fetch only events whose dateTime is in the future
    const upcomingEvents = await Event.find({ dateTime: { $gt: currentDateTime } })
      .sort({ dateTime: 1 }); // Sort events in ascending order (earliest first)
    console.log("upcoming:",upcomingEvents);
    res.status(200).json({ status: "success", events: upcomingEvents });

  } catch (error) {
    console.error("❌ Error fetching upcoming events:", error);
    res.status(500).json({ message: "Failed to fetch upcoming events" });
  }
};

//  Export functions properly
export default { createEvent, getEvents , getUpcomingEvents};

