// server/index.js
const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');
const testRoute = require('./modules/test/testRoute');
const CalendarController = require('./modules/calendar/calendarController');

dotenv.config();

const app = express();
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

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});

app.get('/user/:outlookId/events/:date', CalendarController.getUserEvents);

app.post('/user/:outlookId/reminder', CalendarController.setPersonalReminderTime);
