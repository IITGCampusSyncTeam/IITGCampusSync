import Event from './eventModel.js';
import User from '../user/user.model.js';
import {admin} from '../firebase/firebase_controller.js';

// Convert IST to UTC
function convertISTtoUTC(istDateTime) {
    const dateIST = new Date(istDateTime);
    const utcDateTime = new Date(dateIST.getTime() - (5.5 * 60 * 60 * 1000)); // Subtract 5 hours 30 minutes
    return utcDateTime.toISOString(); // Save as UTC string
}

// Function to create an event
async function createEvent(req, res) {
    try {
        const { title, description, dateTime, club, createdBy } = req.body;

        // Convert IST to UTC before saving
        const dateTimeUTC = convertISTtoUTC(dateTime);
        console.log("📅 Converted DateTime (IST to UTC):", dateTimeUTC);

        // Fetch the club and populate followers
        const associatedClub = await Club.findById(club).populate('followers');

        if (!associatedClub) {
            return res.status(404).json({ status: "error", message: "Club not found" });
        }

        console.log("Associated Club:", associatedClub.name);
        console.log("Followers of Club:", associatedClub.followers.length);

        // Get FCM tokens of followers
        const fcmTokens = associatedClub.followers
            .filter(user => user.fcmToken) // Filter only users with valid FCM tokens
            .map(user => user.fcmToken);

        console.log("✅ FCM Tokens of Club Followers:", fcmTokens);

        // Save event in MongoDB
        const newEvent = await Event.create({
            title,
            description,
            dateTimeUTC,
            club,
            createdBy,
            participants: associatedClub.followers.map(user => user._id), // Store follower IDs
            notifications: [],
        });

        console.log("✅ Event Created Successfully:", newEvent);

//TODO: if we r using for loop then will take lot of time, performance issue
        // Send notifications to club followers
        if (fcmTokens.length > 0) {
            for (const token of fcmTokens) {
                const message = {
                    notification: {
                        title: `New Event: ${title}`,
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
            console.log("⚠️ No FCM tokens found for club followers, skipping notifications.");
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
      .sort({ dateTime: 1 }).limit(10); // Sort events in ascending order (earliest first)
    console.log("upcoming:",upcomingEvents);
    res.status(200).json({ status: "success", events: upcomingEvents });

  } catch (error) {
    console.error("❌ Error fetching upcoming events:", error);
    res.status(500).json({ message: "Failed to fetch upcoming events" });
  }
};

 // func to get past events of the club
 const getPastEventsOfClub = async (req, res) => {
  try {
    const { clubId } = req.params;

    if (!clubId) {
      return res.status(400).json({ error: 'Missing clubId in request params' });
    }

    const pastEvents = await EventModel.find({
      club: clubId,
      dateTime: { $lt: new Date() },
    }).sort({ dateTime: -1 }); // sort by newest to oldest

    res.status(200).json({ pastEvents });
  } catch (error) {
    console.error('Error fetching past events:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

//func for fetching events of followed clubs
export const getFollowedClubEvents = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    // Find clubs followed by the user
    const followedClubs = await Club.find({ followers: userId }).populate('events');

    if (!followedClubs.length) {
      return res.status(404).json({ error: 'User is not following any clubs' });
    }

    // Collect events from all followed clubs
    let allEvents = [];
    followedClubs.forEach(club => {
      allEvents = allEvents.concat(club.events);
    });

    // Optional: Sort events by date
    allEvents.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));

    res.status(200).json(allEvents);
  } catch (error) {
    console.error('Error fetching events from followed clubs:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};


// Function to update event status
export const updateEventStatus = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { status } = req.body;

    const validStatuses = ['drafted', 'tentative', 'published'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status value' });
    }

    const updatedEvent = await EventModel.findByIdAndUpdate(
      eventId,
      { status },
      { new: true }
    );

    if (!updatedEvent) {
      return res.status(404).json({ error: 'Event not found' });
    }

    res.status(200).json({ message: 'Event status updated', updatedEvent });
  } catch (error) {
    console.error('Error updating event status:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

//  Export functions properly
export default { createEvent, getEvents , getUpcomingEvents, getPastEventsOfClub, getFollowedClubEvents, updateEventStatus};

 // Function to create an event
//async function createEvent(req, res) {
//  try {
//    const { title, description, dateTime, club, createdBy } = req.body;
// // Convert IST to UTC before saving
//    const dateTimeUTC = convertISTtoUTC(dateTime);
//    console.log("📅 Converted DateTime (IST to UTC):", dateTimeUTC);
//    //  Fetch all users who have an FCM token
//    const users = await User.find({ fcmToken: { $exists: true, $ne: null } });
//
//    console.log(" Fetched Users with FCM Tokens:", users);
//
//    //  Extract user IDs for participants and FCM tokens separately
//    const participants = users.map(user => user._id);  // Store only ObjectIds
//    const fcmTokens = users.map(user => user.fcmToken); // Store FCM tokens separately
//
//    console.log("✅ Processed Participants (ObjectIds):", participants);
//    console.log("✅ FCM Tokens for Notifications:", fcmTokens);
//
//    // Save event in MongoDB
//    const newEvent = await Event.create({
//      title,
//      description,
//      dateTimeUTC,
//      club,
//      createdBy,
//      participants, // Now stores only ObjectIds
//      notifications: [],
//    });
//
//    console.log(" Event Created Successfully:", newEvent);
////TODO: if we r using for loop then will take lot of time, performance issue
//    //  Send notifications only if participants exist
//    if (fcmTokens.length > 0) {
//      for (const token of fcmTokens) {
//        const message = {
//          notification: {
//            title: title,
//            body: description,
//          },
//          token: token,
//        };
//
//        try {
//          const response = await admin.messaging().send(message);
//          console.log("✅ Notification sent successfully:", response);
//        } catch (error) {
//          console.error("❌ Error sending notification:", error);
//        }
//      }
//    } else {
//      console.log("⚠️ No FCM tokens found, skipping notifications.");
//    }
//
//    res.status(201).json({ status: "success", event: newEvent });
//  } catch (error) {
//    console.error("❌ Error creating event:", error);
//    res.status(500).json({ status: "error", message: "Internal Server Error" });
//  }
//}