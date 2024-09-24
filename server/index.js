// server/index.js
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const testRoute = require('./modules/test/testRoute');
const admin = require('firebase-admin');
const path = require('path');
// Import your Event model
const Event = require('./modules/event/eventModel.js');
const User= require('./modules/user/userModel.js');

dotenv.config();

const app = express();
//app.use(bodyParser.json());
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

 
// MongoDB connection
mongoose.connect(process.env.MONGODB_URI||"mongodb+srv://simonrema123:6K8peORWEGUl15uZ@cluster0.2p9ue.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0", { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log('MongoDB connected'))
    .catch((err) => console.log(err));

// Basic route
app.get('/', (req, res) => {
    res.send('Backend is running');
});

// hello route
app.get('/hello', (req, res) => {
    res.send('Hello from server');
});
//test route
app.use('/api/test', testRoute);

// Specify the path to your service account key file
const serviceAccountPath = path.join(__dirname, 'config', 'iitg-campus-sync.json');

// Initialize Firebase Admin SDK
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath)
  });
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error);
  process.exit(1);
}

// Update User FCM Token Route
app.post('/register-token', async (req, res) => {
  const { userId, fcmToken } = req.body; // Ensure this matches what you're sending from Flutter

  try {
    await User.updateOne({ _id: userId }, { fcmToken }, { upsert: true });
    res.status(200).json({ message: 'FCM token registered successfully' });
  } catch (error) {
    console.error('Error registering token:', error);
    res.status(500).json({ error: 'Failed to register token' });
  }
});

// Route to create an event and send notifications
app.post('/create-event', async (req, res) => {
    const { title, description, dateTime, club, createdBy, participants } = req.body;

    try {
        // Create event logic
        const event = Event(req.body);
        await event.save();

        // Get FCM tokens of all participants
        const fcmTokens = await getFcmTokensOfUsers(participants);

        // Check if tokens are available
        if (fcmTokens.length > 0) {
            // Send notifications
            const message = {
                notification: {
                    title: 'New Event Created',
                    body: `${title} is happening soon!`
                },
                tokens: fcmTokens
            };

            const response = await admin.messaging().sendMulticast(message);
            console.log('Successfully sent notifications:', response);
        } else {
            console.log('No FCM tokens available to send notifications');
        }

        res.status(201).json({ message: 'Event created and notifications sent', event });
    } catch (err) {
        console.error('Error creating event or sending notifications:', err);
        res.status(500).json({ error: 'Error creating event or sending notifications' });
    }
});

app.get('/get-events', async (req, res) => {
  try {
    const events = await Event.find();
    res.status(200).json(events);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ message: 'Failed to fetch events' });
  }
});


// Route to save FCM token
app.post('/save-token', async (req, res) => {
    const { userId, fcmToken } = req.body;

    try {
        // Find the user by ID and update their FCM token
        const user = await User.findById(userId);
        if (user) {
            user.fcmToken = fcmToken;
            await user.save();
            res.status(200).json({ message: 'FCM token saved successfully' });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (err) {
        console.error('Error saving FCM token:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Function to get FCM tokens of all users
async function getFcmTokensOfUsers(userIds) {
    try {
        // Find users by their IDs and return their FCM tokens
        const users = await User.find({ _id: { $in: userIds } });
        const fcmTokens = users.map(user => user.fcmToken).filter(token => token !== undefined);

        return fcmTokens;
    } catch (err) {
        console.error('Error retrieving FCM tokens:', err);
        throw err;
    }
}

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
