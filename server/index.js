// Import necessary modules
import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';

// Import routes
import authRoutes from './modules/auth/auth_route.js'; // Ensure '.js' is included in the path
import clubRoutes from './modules/clubs/clubRoutes.js';
import CalendarController from './modules/calendar/calendarController.js';
import userRoutes from './modules/user/user.route.js';
import cookieParser from 'cookie-parser';



// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cookieParser());
// MongoDB connection
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://a30748235:IITGsync@cluster0.hnflu.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0', {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('MongoDB connected');
    } catch (err) {
        console.error('MongoDB connection error:', err);
        process.exit(1); // Exit process with failure
    }
};
connectDB();

// Basic route
app.get('/', (req, res) => {
    res.send('Backend is running..');
});

// Hello route
app.get('/hello', (req, res) => {
    res.send('Hello from server');
});

// Auth routes
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(err.status || 500).json({
        status: 'error',
        message: err.message || 'Internal Server Error',
    });
});

// Clubs routes
app.use("/api/clubs", clubRoutes);

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port: ${PORT}`);
});

app.get('/user/:outlookId/events/:date', CalendarController.getUserEvents);

app.post('/user/:outlookId/reminder', CalendarController.setPersonalReminderTime);

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

// GET request to retrieve FCM tokens
app.get('/get-tokens', async (req, res) => {
    try {
        const users = await User.find({});
        // Extract fcmToken and filter out undefined or empty tokens
        const tokens = users
            .map(user => user.fcmToken)
            .filter(token => typeof token === 'string' && token.trim() !== '');

        res.json(tokens);
    } catch (error) {
        console.error('Error fetching tokens:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});
