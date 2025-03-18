import Event from './eventModel.js';
import User from '../user/user.model.js'; // Assuming user model exists

// Function to create an event
const createEvent = async (req, res) => {
  const { title, description, dateTime, club, createdBy, participants } = req.body;

  if (!title || !description) {
    return res.status(400).send('Missing required fields: title, description');
  }

  try {
    const event = new Event(req.body);
    await event.save();
    res.status(201).json({ message: 'Event created successfully', event });
  } catch (err) {
    console.error('Error creating event:', err);
    res.status(500).json({ error: 'Error creating event' });
  }
};

// Function to fetch all events
const getEvents = async (req, res) => {
  try {
    const events = await Event.find();
    res.status(200).json(events);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch events' });
  }
};

const getUpcomingEvents = async (req, res) => {
  try {
    const currentDate = new Date();
    console.log("Current Date:", currentDate); // Debugging

    const upcomingEvents = await Event.find({
      dateTime: { $exists: true, $gte: currentDate },
    }).sort({ dateTime: 1 });

    console.log("Fetched Upcoming Events:", upcomingEvents); // Debugging
    res.status(200).json(upcomingEvents);
  } catch (error) {
    console.error("Error fetching upcoming events:", error);
    res.status(500).json({ message: "Failed to fetch upcoming events" });
  }
};


// Function to fetch events from followed clubs
const getFollowedClubEvents = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const followedClubs = user.followedClubs; // Assuming user model has followedClubs array

    const events = await Event.find({ club: { $in: followedClubs } }).sort({ dateTime: 1 });
    res.status(200).json(events);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch followed club events' });
  }
};

// Function to fetch events based on user's interests
const getInterestEvents = async (req, res) => {
  const { userId } = req.params;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const interests = user.interests; // Assuming user model has interests array

    const events = await Event.find({ categories: { $in: interests } }).sort({ dateTime: 1 });
    res.status(200).json(events);
  } catch (error) {
    res.status(500).json({ message: 'Failed to fetch interest-based events' });
  }
};

export default {
  createEvent,
  getEvents,
  getUpcomingEvents,
  getFollowedClubEvents,
  getInterestEvents,
};
