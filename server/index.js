const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const testRoute = require('./modules/test/testRoute');
const admin = require('firebase-admin');
const path = require('path');
const eventController = require('./modules/event/eventController'); // Import the event controller
const User = require('./modules/user/userModel.js');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || "mongodb+srv://simonrema123:6K8peORWEGUl15uZ@cluster0.2p9ue.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0", { useNewUrlParser: true, useUnifiedTopology: true })
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

// test route
app.use('/api/test', testRoute);

// Initialize Firebase Admin SDK
const serviceAccountPath = path.join(__dirname, 'config', 'iitg-campus-sync.json');
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath),
  });
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error);
  process.exit(1);
}

// Routes to create event and fetch events (now handled by eventController)
app.post('/create-event', eventController.createEvent);
app.get('/get-events', eventController.getEvents);


// Route to save FCM token
app.post('/save-token', async (req, res) => {
  const { userId, fcmToken } = req.body;

  try {
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

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

