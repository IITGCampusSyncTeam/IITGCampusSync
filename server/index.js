import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';
import { fileURLToPath } from 'node:url'; // Using node:url
import Razorpay from "razorpay";
import crypto from "crypto";
import cors from "cors";
// Import routes
import authRoutes from './modules/auth/auth_route.js';
import clubRoutes from './modules/club/clubRoutes.js';
import CalendarController from './modules/calendar/calendarController.js';
import userRoutes from './modules/user/user.route.js';
import eventController from './modules/event/eventController.js';
import User from './modules/user/user.model.js';
import contestRoutes from './modules/contest/routes.js';
import orderRoutes from "./modules/orders/ordersRoutes.js";
import firebaseRoutes from './modules/firebase/firebase_routes.js';
import paymentRoutes from './modules/payment/payment_routes.js';
import eventRoutes from './modules/event/eventRoutes.js'
// Load environment variables
//dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;


// Middleware
app.use(express.json());
app.use(cookieParser());
app.use(cors());

// MongoDB connection
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI, {
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
//import admin from 'firebase-admin';


// const __dirname = path.dirname(fileURLToPath(import.meta.url));
// const serviceAccountPath = path.join(__dirname, 'config', 'iitg-campus-sync.json');

// Check if the file exists at the constructed path

// import fs from 'fs';
// if (!fs.existsSync(serviceAccountPath)) {
//     console.error(`Service account file not found at path: ${serviceAccountPath}`);
//     process.exit(1); // Exit the app if the file is not found
// }
//if (!process.env.FIREBASE_SERVICE_ACCOUNT) {
//    console.error('FIREBASE_SERVICE_ACCOUNT environment variable is not set.');
//    process.exit(1);
//}
//
//try {
//  const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
//
//  admin.initializeApp({
//    credential: admin.credential.cert(serviceAccount),
//  });
//} catch (error) {
//  console.error('Error initializing Firebase Admin SDK:', error);
//  process.exit(1);
//}

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

//event routes
app.use("/api/events", eventRoutes);

//routes
app.use("/api/firebase", firebaseRoutes);
app.use("/api/payments", paymentRoutes);

// Save FCM token (Firebase Related - Commenting Out)
//app.post('/save-token', async (req, res) => {
//  const { userId, fcmToken } = req.body;
//
//  try {
//    const user = await User.findById(userId);
//    if (user) {
//      user.fcmToken = fcmToken;
//      await user.save();
//      res.status(200).json({ message: 'FCM token saved successfully' });
//    } else {
//      res.status(404).json({ message: 'User not found' });
//    }
//  } catch (err) {
//    console.error('Error saving FCM token:', err);
//    res.status(500).json({ error: 'Internal server error' });
//  }
//});

// GET request to retrieve FCM tokens (Commented Out)
//app.get('/get-tokens', async (req, res) => {
//    try {
//        const users = await User.find({});
//        const tokens = users
//            .map(user => user.fcmToken)
//            .filter(token => typeof token === 'string' && token.trim() !== '');
//
//        res.json(tokens);
//    } catch (error) {
//        console.error('Error fetching tokens:', error);
//        res.status(500).json({ error: 'Internal Server Error' });
//    }
//});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(err.status || 500).json({
        status: 'error',
        message: err.message || 'Internal Server Error',
    });
});

// Securely return the Razorpay Key
//app.get("/get-razorpay-key", (req, res) => {
//  res.json({ key: process.env.RAZORPAY_KEY_ID});
//});

////payment
//const razorpay = new Razorpay({
//  key_id: process.env.RAZORPAY_KEY_ID,
//  key_secret: process.env.RAZORPAY_KEY_SECRET,
//});
// Create Order API
//app.post("/create-order", async (req, res) => {
//  try {
//    const options = {
//      amount: req.body.amount * 100, // Convert to paise
//      currency: "INR",
//      receipt: "order_rcptid_11",
//    };
//
//    const order = await razorpay.orders.create(options);
//    res.json(order);
//  } catch (error) {
//    res.status(500).send(error);
//  }
//});
// Verify Payment API
//app.post("/verify-payment", async (req, res) => {
//  const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
//
//  const generated_signature = crypto
//    .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
//    .update(razorpay_order_id + "|" + razorpay_payment_id)
//    .digest("hex");
//
//  if (generated_signature === razorpay_signature) {
//    res.json({ success: true, message: "Payment verified successfully" });
//  } else {
//    res.status(400).json({ success: false, message: "Payment verification failed" });
//  }
//});

app.get("/get-service-account", (req, res) => {
  try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
    res.json({ client_email: serviceAccount.client_email, project_id: serviceAccount.project_id , private_key: serviceAccount.private_key});
  } catch (error) {
    console.error("Error loading service account:", error);
    res.status(500).json({ error: "Failed to load credentials" });
  }
});

// Start the server
app.listen(3000, '0.0.0.0', () => {
    console.log("Server running on port 3000");
});

