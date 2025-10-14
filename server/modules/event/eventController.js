import Event from './eventModel.js';
import User from '../user/user.model.js';
import { admin } from '../firebase/firebase_controller.js';
import Club from '../club/clubModel.js';
import { broadcast } from '../../index.js';
import EventRegistration from '../eventRegistration/eventRegistrationModel.js';
import catchAsync from '../../utils/catchAsync.js';

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
export const getEvents = async (req, res) => {
  try {

    const events = await Event.find()
      .populate('participants')
      .populate({ path: 'club' })
      .populate({ path: 'tag' })
      .lean();

    // Check if a user is logged in
    if (req.user) {
      const userId = req.user.id;


      const eventIds = events.map(event => event._id);

      // to find all registrations for the current user that match the fetched events
      const userRegistrations = await EventRegistration.find({
        user: userId,
        event: { $in: eventIds }
      });

      // Create a Set of event IDs the user has RSVP'd to for quick checking
      const rsvpdEventIds = new Set(
        userRegistrations.map(reg => reg.event.toString())
      );


      events.forEach(event => {
        event.isRsvpd = rsvpdEventIds.has(event._id.toString());
      });
    } else {

      events.forEach(event => {
        event.isRsvpd = false;
      });
    }

    res.status(200).json(events);
  } catch (error) {
    console.error("❌ Error fetching events:", error);
    res.status(500).json({ message: "Failed to fetch events" });
  }
};

// Function to get upcoming events
export const getUpcomingEvents = async (req, res) => {
  try {
    const currentDateTime = new Date();

    // Fetch only events whose dateTime is in the future
    const upcomingEvents = await Event.find({ dateTime: { $gt: currentDateTime } })
      .sort({ dateTime: 1 }).limit(10); // Sort events in ascending order (earliest first)
    console.log("upcoming:", upcomingEvents);
    res.status(200).json({ status: "success", events: upcomingEvents });

  } catch (error) {
    console.error("❌ Error fetching upcoming events:", error);
    res.status(500).json({ message: "Failed to fetch upcoming events" });
  }
};

 // func to get past events of the club
export const getPastEventsOfClub = async (req, res) => {
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

export const editEvent = async (req, res) => {
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
export const createTentativeEvent = async (req, res) => {
  try {
    const { title, datetime, venue,isSeries,openTo,isOffline,tag,seriesName } = req.body;

    if (!title || !datetime || !venue||!openTo||!tag) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const newEvent = await Event.create({
      title,
      description: "Tentative Event", // optional default
      dateTime: new Date(datetime), // assuming frontend sends ISO string
      venue,
      tag:tag,
      venueType:isOffline? 'On-Campus':'Online',
      status: "tentative",
      series:isSeries ? seriesName:'NA'
    });

    return res.status(201).json({ message: "Tentative event created", event: newEvent });
  } catch (error) {
    console.error("Error creating tentative event:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
};

// GET UPCOMING EVENTS A USER HAS RSVP'D FOR
export const getRsvpdUpcomingEvents = async (req, res, next) => {
  const userId = req.user.id;
  const events = await Event.find({
    dateTime: { $gte: new Date() }, // Events in the future
    rsvp: userId, // Where the user's ID is in the 'rsvp' array
  }).sort({ dateTime: 1 }).lean();

  events.forEach(event => event.isRsvpd = true); // User has RSVP'd for all these
  res.status(200).json({ events });
};

//export const getActiveCreatorEvents = async (req, res) => {
//  try {
//    const { createdBy } = req.params;
//
//    if (!createdBy) {
//      return res.status(400).json({ message: 'Missing Creator ID!!' });
//    }
//
//    // Upcoming events: published and in the future
//    const Events = await Event.find({
//      createdBy: createdBy,
//    });
//
//
//    return res.status(200).json({
//      Events
//    });
//  } catch (error) {
//    console.error("Error fetching creator events:", error);
//    return res.status(500).json({ message: "Internal Server Error" });
//  }
//};

// GET PAST EVENTS A USER HAS RSVP'D FOR
export const getAttendedEvents = async (req, res, next) => {
  const userId = req.user.id;
  const events = await Event.find({
    dateTime: { $lt: new Date() }, // Events in the past
    rsvp: userId, // Where the user's ID is in the 'rsvp' array
  }).sort({ dateTime: -1 }).lean();

  res.status(200).json({ events });
};

export const getCreatorEvents = async (req, res) => {
  try {
    const { createdBy } = req.body;
    const now = Date.now();

    if (!createdBy) {
      return res.status(400).json({ message: 'Missing Creator ID!!' });
    }

    // Upcoming events: published and in the future
    const upcomingEvents = await Event.find({
      createdBy: createdBy,
      status: 'published',
      dateTime: { $gt: now }
    });

    // Ongoing events: status is 'live'
    const ongoingEvents = await Event.find({
      createdBy: createdBy,
      status: 'live'
    });

    return res.status(200).json({
      ongoingEvents,
      upcomingEvents
    });
  } catch (error) {
    console.error("Error fetching creator events:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
};

// function to add students to rsvp list of an event
export const rsvpToEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { userId, status } = req.body; // status can be: "yes", "no", "maybe"

    if (!eventId || !userId || !status) {
      return res.status(400).json({ status: "error", message: "Missing eventId, userId or status" });
    }

    const validStatuses = ["yes", "no", "maybe"];
    if (!validStatuses.includes(status.toLowerCase())) {
      return res.status(400).json({ status: "error", message: "Invalid RSVP status" });
    }

    const event = await Event.findById(eventId);
    if (!event) {
      return res.status(404).json({ status: "error", message: "Event not found" });
    }

    // check if the user already RSVPed
    const existing = event.RSVP.find(r => r.user.toString() === userId);

    if (existing) {
      existing.status = status.toLowerCase();
      existing.timestamp = new Date();
    } else {
      event.RSVP.push({
        user: userId,
        status: status.toLowerCase(),
        timestamp: new Date()
      });
    }

    await event.save();

    res.status(200).json({ status: "success", message: "RSVP recorded", RSVP: event.RSVP });
  } catch (error) {
    console.error("❌ Error RSVPing to event:", error);
    res.status(500).json({ status: "error", message: "Internal server error" });
  }
};

// Admin fetches RSVP list of an event
export const getEventRSVPs = async (req, res) => {
  try {
    const { eventId } = req.params;

    if (!eventId) return res.status(400).json({ status: "error", message: "Missing eventId" });

    const event = await Event.findById(eventId)
      .populate('RSVP.user', 'username email profilePicture');

    if (!event) return res.status(404).json({ status: "error", message: "Event not found" });

    res.status(200).json({ status: "success", eventId, RSVP: event.RSVP });
  } catch (error) {
    console.error("❌ Error fetching RSVPs:", error);
    res.status(500).json({ status: "error", message: "Internal server error" });
  }
};

//  Export functions properly
//export default { createEvent, getEvents, getUpcomingEvents, getPastEventsOfClub, getFollowedClubEvents, updateEventStatus, editEvent, createTentativeEvent, getActiveCreatorEvents, rsvpToEvent, getEventRSVPs };

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