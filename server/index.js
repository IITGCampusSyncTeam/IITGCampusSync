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
