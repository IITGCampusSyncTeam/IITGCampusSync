import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';
import cors from "cors";
// Import routes
import authRoutes from './modules/auth/auth_route.js';
import clubRoutes from './modules/club/clubRoutes.js';
import CalendarController from './modules/calendar/calendarController.js';
import userRoutes from './modules/user/user.route.js';
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

//contest Routes
app.use("/api/contest", contestRoutes);

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


// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(err.status || 500).json({
        status: 'error',
        message: err.message || 'Internal Server Error',
    });
});



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

