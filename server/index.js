import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';

// Import routes
import authRoutes from './modules/auth/auth_route.js';
import clubRoutes from './modules/club/clubRoutes.js';
import CalendarController from './modules/calendar/calendarController.js';
import userRoutes from './modules/user/user.route.js';
import eventController from './modules/event/eventController.js';
import User from './modules/user/user.model.js';
import contestRoutes from './modules/contest/routes.js';
import orderRoutes from "./modules/orders/ordersRoutes.js";

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(express.json());
app.use(cookieParser());

// MongoDB connection
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://ayushkr7054:9PCB80SYnTcfYuOt@iitgsync.luimi.mongodb.net/?retryWrites=true&w=majority&appName=IITGSYNC', {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('MongoDB connected');
    } catch (err) {
        console.error('MongoDB connection error:', err);
        process.exit(1);
    }
};
connectDB();

app.use("/api/contest", contestRoutes);

// 🔴 Commented out Firebase Admin SDK
// import admin from 'firebase-admin';
// import path from 'node:path';
// import { fileURLToPath } from 'node:url';
// import fs from 'fs';

// const __dirname = path.dirname(fileURLToPath(import.meta.url));
// const serviceAccountPath = path.join(__dirname, 'config', 'iitg-campus-sync.json');

// if (!fs.existsSync(serviceAccountPath)) {
//     console.error(`Service account file not found at path: ${serviceAccountPath}`);
//     process.exit(1);
// }

// try {
//   admin.initializeApp({
//     credential: admin.credential.cert(serviceAccountPath),
//   });
// } catch (error) {
//   console.error('Error initializing Firebase Admin SDK:', error);
//   process.exit(1);
// }

// Basic route
app.get('/', (req, res) => {
    res.send('Backend is running..');
});

app.get('/hello', (req, res) => {
    res.send('Hello from server');
});

// Auth routes
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);

// Clubs routes
app.use("/api/clubs", clubRoutes);

//orderRoutes
app.use("/api/orders", orderRoutes);

// Calendar routes
app.get('/user/:outlookId/events/:date', CalendarController.getUserEvents);
app.post('/user/:outlookId/reminder', CalendarController.setPersonalReminderTime);

// Routes to create event and fetch events
app.post('/create-event', eventController.createEvent);
app.get('/get-events', eventController.getEvents);

// Save FCM token (Firebase Related - Commenting Out)
// app.post('/save-token', async (req, res) => {
//   const { userId, fcmToken } = req.body;

//   try {
//     const user = await User.findById(userId);
//     if (user) {
//       user.fcmToken = fcmToken;
//       await user.save();
//       res.status(200).json({ message: 'FCM token saved successfully' });
//     } else {
//       res.status(404).json({ message: 'User not found' });
//     }
//   } catch (err) {
//     console.error('Error saving FCM token:', err);
//     res.status(500).json({ error: 'Internal server error' });
//   }
// });

// GET request to retrieve FCM tokens (Commented Out)
// app.get('/get-tokens', async (req, res) => {
//     try {
//         const users = await User.find({});
//         const tokens = users
//             .map(user => user.fcmToken)
//             .filter(token => typeof token === 'string' && token.trim() !== '');

//         res.json(tokens);
//     } catch (error) {
//         console.error('Error fetching tokens:', error);
//         res.status(500).json({ error: 'Internal Server Error' });
//     }
// });

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(err.status || 500).json({
        status: 'error',
        message: err.message || 'Internal Server Error',
    });
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
