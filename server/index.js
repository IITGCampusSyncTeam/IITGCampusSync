import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
<<<<<<< HEAD
import path from 'node:path'; // Using node:path
// import admin from 'firebase-admin'; // Firebase removed
import cookieParser from 'cookie-parser';
import { fileURLToPath } from 'node:url'; // Using node:url

=======
import cookieParser from 'cookie-parser';
import { fileURLToPath } from 'node:url'; // Using node:url
import Razorpay from "razorpay";
import crypto from "crypto";
import cors from "cors";
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
// Import routes
import authRoutes from './modules/auth/auth_route.js';
import clubRoutes from './modules/club/clubRoutes.js';
import CalendarController from './modules/calendar/calendarController.js';
import userRoutes from './modules/user/user.route.js';
<<<<<<< HEAD
import eventController from './modules/event/eventController.js'; // Import eventController
import User from './modules/user/user.model.js';
import contestRoutes from './modules/contest/routes.js';
import acadRoutes from "./modules/acadcalender/acadcalRoutes.js"; // Import academic calendar routes
=======
import eventController from './modules/event/eventController.js';
import User from './modules/user/user.model.js';
import contestRoutes from './modules/contest/routes.js';
import orderRoutes from "./modules/orders/ordersRoutes.js";
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

<<<<<<< HEAD
// Middleware
app.use(express.json());
// app.use(cookieParser());
=======

// Middleware
app.use(express.json());
app.use(cookieParser());
app.use(cors());
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050

// MongoDB connection
const connectDB = async () => {
    try {
<<<<<<< HEAD
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb+srv://ayushkr7054:9PCB80SYnTcfYuOt@iitgsync.luimi.mongodb.net/?retryWrites=true&w=majority&appName=IITGSYNC', {
=======
        await mongoose.connect(process.env.MONGODB_URI, {
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
        console.log('MongoDB connected');
    } catch (err) {
        console.error('MongoDB connection error:', err);
<<<<<<< HEAD
        process.exit(1); // Exit process with failure
=======
        process.exit(1);
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
    }
};
connectDB();

<<<<<<< HEAD
app.use("/api/contest", contestRoutes); // Add contest routes

// ✅ Firebase-related code has been commented out below

// // Correct the path construction for service account
// const __dirname = path.dirname(fileURLToPath(import.meta.url));  // Get __dirname equivalent in ES Modules
// const serviceAccountPath = path.join(__dirname, 'config', 'iitg-campus-sync.json');

// // Check if the file exists at the constructed path
=======
app.use("/api/contest", contestRoutes);

// 🔴 Commented out Firebase Admin SDK
import admin from 'firebase-admin';


// const __dirname = path.dirname(fileURLToPath(import.meta.url));
// const serviceAccountPath = path.join(__dirname, 'config', 'iitg-campus-sync.json');

// Check if the file exists at the constructed path

>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
// import fs from 'fs';
// if (!fs.existsSync(serviceAccountPath)) {
//     console.error(`Service account file not found at path: ${serviceAccountPath}`);
//     process.exit(1); // Exit the app if the file is not found
// }
<<<<<<< HEAD

// // Initialize Firebase Admin SDK
// try {
//   admin.initializeApp({
//     credential: admin.credential.cert(serviceAccountPath),
//   });
// } catch (error) {
//   console.error('Error initializing Firebase Admin SDK:', error);
//   process.exit(1);
// }
=======
if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
    console.error('FIREBASE_SERVICE_ACCOUNT environment variable is not set.');
    process.exit(1);
}

try {
  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error);
  process.exit(1);
}
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050

// Basic route
app.get('/', (req, res) => {
    res.send('Backend is running..');
});

<<<<<<< HEAD
// Hello route
=======
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
app.get('/hello', (req, res) => {
    res.send('Hello from server');
});

// Auth routes
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);

// Clubs routes
app.use("/api/clubs", clubRoutes);
<<<<<<< HEAD
app.use('/api/acadcal', acadRoutes); // Add academic calendar routes

// ✅ Firebase-related routes commented out below

// // Calendar routes
// app.get('/user/:outlookId/events/:date', CalendarController.getUserEvents);
// app.post('/user/:outlookId/reminder', CalendarController.setPersonalReminderTime);

// // Routes to create event and fetch events
// app.post('/create-event', eventController.createEvent);
// app.get('/get-events', eventController.getEvents);

// // Save FCM token (Firebase Cloud Messaging)
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

// // GET request to retrieve FCM tokens
// app.get('/get-tokens', async (req, res) => {
//     try {
//         const users = await User.find({});
//         // Extract fcmToken and filter out undefined or empty tokens
//         const tokens = users
//             .map(user => user.fcmToken)
//             .filter(token => typeof token === 'string' && token.trim() !== '');

//         res.json(tokens);
//     } catch (error) {
//         console.error('Error fetching tokens:', error);
//         res.status(500).json({ error: 'Internal Server Error' });
//     }
// });
=======

//orderRoutes
app.use("/api/orders", orderRoutes);

// Calendar routes
app.get('/user/:outlookId/events/:date', CalendarController.getUserEvents);
app.post('/user/:outlookId/reminder', CalendarController.setPersonalReminderTime);

// Routes to create event and fetch events
app.post('/create-event', eventController.createEvent);
app.get('/get-events', eventController.getEvents);

// Save FCM token (Firebase Related - Commenting Out)
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

// GET request to retrieve FCM tokens (Commented Out)
app.get('/get-tokens', async (req, res) => {
    try {
        const users = await User.find({});
        const tokens = users
            .map(user => user.fcmToken)
            .filter(token => typeof token === 'string' && token.trim() !== '');

        res.json(tokens);
    } catch (error) {
        console.error('Error fetching tokens:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(err.status || 500).json({
        status: 'error',
        message: err.message || 'Internal Server Error',
    });
});

<<<<<<< HEAD
// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
=======
// Securely return the Razorpay Key
app.get("/get-razorpay-key", (req, res) => {
  res.json({ key: process.env.RAZORPAY_KEY_ID});
});

//payment
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});
// Create Order API
app.post("/create-order", async (req, res) => {
  try {
    const options = {
      amount: req.body.amount * 100, // Convert to paise
      currency: "INR",
      receipt: "order_rcptid_11",
    };

    const order = await razorpay.orders.create(options);
    res.json(order);
  } catch (error) {
    res.status(500).send(error);
  }
});
// Verify Payment API
app.post("/verify-payment", async (req, res) => {
  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

  const generated_signature = crypto
    .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
    .update(razorpay_order_id + "|" + razorpay_payment_id)
    .digest("hex");

  if (generated_signature === razorpay_signature) {
    res.json({ success: true, message: "Payment verified successfully" });
  } else {
    res.status(400).json({ success: false, message: "Payment verification failed" });
  }
});

// Start the server
app.listen(3000, '0.0.0.0', () => {
    console.log("Server running on port 3000");
});

>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
