// Use ES module syntax for imports
import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';

// Import routes
import authRoutes from './modules/auth/auth_route.js'; // Ensure '.js' is included in the path
import clubRoutes from './modules/clubs/clubRoutes.js';
import CalendarController from './modules/calendar/calendarController.js';


// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());

// MongoDB connection
mongoose.connect(process.env.MONGODB_URI || "mongodb+srv://a30748235:IITGsync@cluster0.hnflu.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
    .then(() => console.log('MongoDB connected'))
    .catch((err) => console.log(err));

// Basic route
app.get('/', (req, res) => {
    res.send('Backend is running..');
});

// hello route
app.get('/hello', (req, res) => {
    res.send('Hello from server');
});


// Auth routes
app.use("/api/auth", authRoutes);

// Club routes
app.use("/api/clubs", clubRoutes);

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port: ${PORT}`);
});

app.get('/user/:outlookId/events/:date', CalendarController.getUserEvents);

app.post('/user/:outlookId/reminder', CalendarController.setPersonalReminderTime);
