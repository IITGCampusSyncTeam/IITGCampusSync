import Event from './eventModel.js';
import User from '../user/user.model.js';
import { admin } from '../firebase/firebase_controller.js';
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
                    token: token, 
                };

                try {
                    const response = await admin.messaging().send(message);
                    console.log(`✅ Successfully sent FCM message to token ${token.substring(0, 20)}...:`, response); 
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

const getEvents = async (req, res) => {
  try {
    const events = await Event.find().populate('participants').populate({ path: 'club' }).populate({ path: 'tag' });
    console.log(events)
    // Populating for debugging
    //    console.log(" Retrieved Events:", events);
    res.status(200).json(events);
  } catch (error) {
    console.error("❌ Error fetching events:", error);
    res.status(500).json({ message: "Failed to fetch events" });
  }
};

const getUpcomingEvents = async (req, res) => {
  try {
    const currentDateTime = new Date();
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
const getPastEventsOfClub = async (req, res) => {
  try {
    const { clubId } = req.params;
    if (!clubId) {
      return res.status(400).json({ error: 'Missing clubId in request params' });
    }
    const pastEvents = await Event.find({
      club: clubId,
      dateTime: { $lt: new Date() },
    }).sort({ dateTime: -1 }); 
    res.status(200).json({ pastEvents });
  } catch (error) {
    console.error('Error fetching past events:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const getFollowedClubEvents = async (req, res) => {
  try {
    const { userId } = req.params;
    if (!userId) {
      return res.status(400).json({ error: 'Missing userId' });
    }
    const user = await User.findById(userId).populate({
      path: 'subscribedClubs',
      populate: { path: 'events', model: 'Event' }
    });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    const followedClubs = user.subscribedClubs;
    if (!followedClubs || followedClubs.length === 0) {
      return res.status(404).json({ error: 'User is not subscribed to any clubs' });
    }
    let allEvents = [];
    followedClubs.forEach(club => {
      allEvents = allEvents.concat(club.events);
    });
    allEvents.sort((a, b) => new Date(a.dateTime) - new Date(b.dateTime));
    res.status(200).json(allEvents);
  } catch (error) {
    console.error('Error fetching events from subscribed clubs:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

const updateEventStatus = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { status } = req.body;
    const validStatuses = ['drafted', 'tentative', 'published', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: 'Invalid status value' });
    }
    const updatedEvent = await Event.findByIdAndUpdate(
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
    const updatedEvent = await Event.findByIdAndUpdate(
      eventId,
      updateData,
      { new: true } 
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

const createTentativeEvent = async (req, res) => {
  try {
    const { title, date, venue } = req.body;
    if (!title || !date || !venue) {
      return res.status(400).json({ message: "Missing required fields" });
    }
    const newEvent = await Event.create({
      title,
      description: "Tentative Event",
      dateTime: new Date(date),
      venue,
      status: "tentative"
    });
    return res.status(201).json({ message: "Tentative event created", event: newEvent });
  } catch (error) {
    console.error("Error creating tentative event:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
};

/**
 * @description Cancel an event by updating its status to 'cancelled'
 * @route PUT /api/events/:eventId/cancel
 */
const cancelEvent = async (req, res) => {
    try {
        const { eventId } = req.params;
        const updatedEvent = await Event.findByIdAndUpdate(
            eventId,
            { status: 'cancelled' },
            { new: true }
        );
        if (!updatedEvent) {
            return res.status(404).json({ message: 'Event not found' });
        }
        
        // You could also add logic here to notify participants of the cancellation.
        res.status(200).json({ message: 'Event has been cancelled successfully.', event: updatedEvent });
    } catch (error) {
        console.error("Error cancelling event:", error);
        res.status(500).json({ message: 'Internal server error' });
    }
};

const getActiveCreatorEvents = async (req, res) => {
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
const getEventRSVPs = async (req, res) => {
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


/**
 * @description Toggles the registration status for an event
 * @route PUT /api/events/:eventId/pause-registrations
*/
const pauseRegistrations = async (req, res) => {
  try {
    const { eventId } = req.params;
    const event = await Event.findById(eventId);
    
    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }
    
    // Toggle the boolean field
    event.registrationsPaused = !event.registrationsPaused;
    await event.save();
    
    const message = event.registrationsPaused 
    ? 'Registrations have been paused.' 
    : 'Registrations have been resumed.';
    
    res.status(200).json({ message, event });
  } catch (error) {
    console.error("Error pausing registrations:", error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

/**
 * @description Duplicates an existing event as a new draft
 * @route POST /api/events/:eventId/duplicate
*/
const duplicateAsDraft = async (req, res) => {
  try {
    const { eventId } = req.params;
    const originalEvent = await Event.findById(eventId).lean(); // .lean() gives a plain JS object
    
    if (!originalEvent) {
      return res.status(404).json({ message: 'Event not found' });
    }
    
    const newEventData = { ...originalEvent };
    delete newEventData._id; // Remove the original ID to let MongoDB generate a new one
    delete newEventData.__v; // Remove version key
    
    newEventData.title = `(Copy) ${originalEvent.title}`;
    newEventData.status = 'drafted';
    newEventData.participants = []; // Reset participants
    newEventData.feedbacks = []; // Reset feedbacks
    newEventData.notifications = []; // Reset notifications
    newEventData.registrationsPaused = false; // Reset paused status
    newEventData.createdAt = new Date(); // Set a new creation date
    newEventData.updatedAt = new Date(); // Set a new updated date
    
    const duplicatedEvent = new Event(newEventData);
    await duplicatedEvent.save();
    
    res.status(201).json({ message: 'Event duplicated as a draft.', event: duplicatedEvent });
  } catch (error) {
    console.error("Error duplicating event:", error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export default { 
  createEvent, 
  getEvents, 
  getUpcomingEvents, 
  getPastEventsOfClub, 
  getFollowedClubEvents, 
  updateEventStatus, 
  editEvent, 
  createTentativeEvent,
  cancelEvent,
  pauseRegistrations,
  duplicateAsDraft,
  getActiveCreatorEvents,
  rsvpToEvent,
  getEventRSVPs
};
