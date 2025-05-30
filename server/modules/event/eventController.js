import Event from './eventModel.js';
import User from '../user/user.model.js';
import {admin} from '../firebase/firebase_controller.js';
import Club from '../club/clubModel.js';
import { broadcast } from '../../index.js';

// Convert IST to UTC
function convertISTtoUTC(istDateTime) {
    const dateIST = new Date(istDateTime);
    const utcDateTime = new Date(dateIST.getTime() - (5.5 * 60 * 60 * 1000)); // Subtract 5 hours 30 minutes
    return utcDateTime.toISOString(); // Save as UTC string
}

async function createEvent(req, res) {
    try {
        const { title, description, dateTime, club: clubId, createdBy, tag: tagId } = req.body;

        const dateTimeUTC = convertISTtoUTC(dateTime);
        console.log("📅 Converted DateTime (IST to UTC):", dateTimeUTC);

        const associatedClub = await Club.findById(clubId).populate('followers');

        if (!associatedClub) {
            return res.status(404).json({ status: "error", message: "Club not found" });
        }

        console.log("Associated Club:", associatedClub.name);
        console.log("Followers of Club:", associatedClub.followers.length);

        const fcmTokens = associatedClub.followers
            .filter(user => user && user.fcmToken) // Added null check for user
            .map(user => user.fcmToken);

        console.log("✅ FCM Tokens of Club Followers:", fcmTokens);

        let newEvent = await Event.create({
            title,
            description,
            dateTime: dateTimeUTC,
            club: clubId,
            createdBy,
            participants: associatedClub.followers.map(user => user._id),
            notifications: [],
            tag: tagId,
        });

        console.log("✅ Event Created Successfully (pre-population for broadcast):", newEvent._id);

        const populatedEventForBroadcast = await Event.findById(newEvent._id)
            .populate('participants', 'username profilePicture')
            .populate({ path: 'club', select: 'name avatar' })
            .populate({ path: 'tag', select: 'name' });

        if (populatedEventForBroadcast) {
            broadcast({ type: 'EVENT_CREATED', payload: populatedEventForBroadcast });
            console.log('📢 Broadcasted EVENT_CREATED');
        } else {
            console.warn('⚠️ Could not find event for broadcast after creation:', newEvent._id);
        }

        // Send FCM notifications to club followers individually
        if (fcmTokens.length > 0) {
            console.log(`Attempting to send ${fcmTokens.length} FCM messages individually...`);
            let successCount = 0;
            let failureCount = 0;

            for (const token of fcmTokens) {
                const message = {
                    notification: {
                        title: `New Event: ${title}`,
                        body: description,
                    },
                    token: token, // The specific token for this message
                    // data: { eventId: newEvent._id.toString(), type: 'newEvent' } // Optional data payload
                };

                try {
                    // Use admin.messaging().send() for a single message
                    const response = await admin.messaging().send(message);
                    console.log(`✅ Successfully sent FCM message to token ${token.substring(0, 20)}...:`, response); // Log part of token for privacy
                    successCount++;
                } catch (error) {
                    console.error(`❌ Failed to send FCM message to token ${token.substring(0, 20)}...:`, error.code, error.message);
                    failureCount++;
                }
            }
            console.log(`FCM Individual Send Summary: ${successCount} successful, ${failureCount} failed.`);
        } else {
            console.log("⚠️ No FCM tokens found for club followers, skipping notifications.");
        }

        res.status(201).json({ status: "success", event: populatedEventForBroadcast || newEvent });
    } catch (error) {
        console.error("❌ Error creating event:", error);
        res.status(500).json({ status: "error", message: "Internal Server Error" });
    }
}


//  Function to fetch events
const getEvents = async (req, res) => {
  try {
    const events = await Event.find().populate('participants').populate({ path: 'club'}).populate({path:'tag'}); 
    console.log(events)
    // Populating for debugging
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
const getFollowedClubEvents = async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }

    // Find the user and populate their subscribed clubs' events
    const user = await User.findById(userId).populate({
      path: 'subscribedClubs',
      populate: {
        path: 'events',
        model: 'Event'
      }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const followedClubs = user.subscribedClubs;

    if (!followedClubs || followedClubs.length === 0) {
      return res.status(404).json({ error: 'User is not subscribed to any clubs' });
    }

    // Collect all events
    let allEvents = [];
    followedClubs.forEach(club => {
      allEvents = allEvents.concat(club.events);
    });

    // Sort events by date
    allEvents.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));

    res.status(200).json(allEvents);
  } catch (error) {
    console.error('Error fetching events from subscribed clubs:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};


// Function to update event status
const updateEventStatus = async (req, res) => {
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

const editEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    const updateData = req.body;

    if (!eventId) {
      return res.status(400).json({ error: "Missing eventId" });
    }

    const updatedEvent = await EventModel.findByIdAndUpdate(
      eventId,
      updateData,
      { new: true } // return the updated document
    );

    if (!updatedEvent) {
      return res.status(404).json({ error: "Event not found" });
    }

    res.status(200).json({ message: "Event updated successfully", event: updatedEvent });
  } catch (error) {
    console.error("Error updating event:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// Function to create a tentative event
const createTentativeEvent = async (req, res) => {
  try {
    const { title, date, venue } = req.body;

    if (!title || !date || !venue) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const newEvent = await Event.create({
      title,
      description: "Tentative Event", // optional default
      dateTime: new Date(date), // assuming frontend sends ISO string
      venue,
      status: "tentative"
    });

    return res.status(201).json({ message: "Tentative event created", event: newEvent });
  } catch (error) {
    console.error("Error creating tentative event:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
};


//  Export functions properly
export default { createEvent, getEvents , getUpcomingEvents, getPastEventsOfClub, getFollowedClubEvents, updateEventStatus, editEvent,createTentativeEvent};

//func for fetching events of followed clubs
//export const getFollowedClubEvents = async (req, res) => {
//  try {
//    const { userId } = req.params;
//
//    if (!userId) {
//      return res.status(400).json({ error: 'Missing userId' });
//    }
//
//    // Find clubs followed by the user
//    const followedClubs = await Club.find({ followers: userId }).populate('events');
//
//    if (!followedClubs.length) {
//      return res.status(404).json({ error: 'User is not following any clubs' });
//    }
//
//    // Collect events from all followed clubs
//    let allEvents = [];
//    followedClubs.forEach(club => {
//      allEvents = allEvents.concat(club.events);
//    });
//
//    // Optional: Sort events by date
//    allEvents.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));
//
//    res.status(200).json(allEvents);
//  } catch (error) {
//    console.error('Error fetching events from followed clubs:', error);
//    res.status(500).json({ error: 'Internal server error' });
//  }
//};
