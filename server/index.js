import express from 'express';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import cookieParser from 'cookie-parser';
import cors from "cors";
import http from 'http'; // Import http module
import { WebSocketServer } from 'ws'; // Import WebSocketServer from ws

// Import routes
import authRoutes from './modules/auth/auth_route.js';
import clubRoutes from './modules/club/clubRoutes.js';
import CalendarController from './modules/calendar/calendarController.js';
import userRoutes from './modules/user/user.route.js';
import contestRoutes from './modules/contest/routes.js';
import acadRoutes from "./modules/acadcalender/acadcalRoutes.js";
import orderRoutes from "./modules/orders/ordersRoutes.js";
import onedriveRoutes from "./modules/onedrive/onedriveRoutes.js";
import tagRoutes from "./modules/tag/tagRoute.js";
import firebaseRoutes from './modules/firebase/firebase_routes.js';
import paymentRoutes from './modules/payment/payment_routes.js';
import eventRoutes from './modules/event/eventRoutes.js'; // We'll need to modify this later
import notifRoutes from './modules/notif/notification_routes.js';
import cron from 'node-cron';

// Import your Event model (adjust path as necessary)
// Assuming it's something like:
import Event from './modules/event/eventModel.js'; // EXAMPLE: Make sure this path is correct

// Load environment variables
dotenv.config(); // It's good practice to have this uncommented and at the top

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cookieParser());
app.use(cors()); // Consider more specific CORS configuration for production

// MongoDB connection
const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI, {
            // useNewUrlParser and useUnifiedTopology are default true in Mongoose 6+
            // useCreateIndex and useFindAndModify are no longer supported options
        });
        console.log('MongoDB connected');
    } catch (err) {
        console.error('MongoDB connection error:', err);
        process.exit(1);
    }
};
connectDB();

// --- WebSocket Setup ---
const server = http.createServer(app); // Create HTTP server from Express app
const wss = new WebSocketServer({ server }); // Attach WebSocket server

const clients = new Set(); // To store connected WebSocket clients

// Function to broadcast messages to all connected clients
export const broadcast = (data) => { // Export this function
  const jsonData = JSON.stringify(data);
  clients.forEach((client) => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(jsonData);
    }
  });
  console.log(`📢 Broadcasted data: ${JSON.stringify(data.type || data)}`);
};

wss.on('connection', async (ws) => {
  console.log('🚀 Client connected to WebSocket');
  clients.add(ws);

  // Optionally: Send the current list of events to the newly connected client
  try {
    const events = await Event.find() // Assuming Event model is correctly imported
      .populate('participants')
      .populate({ path: 'club' })
      .populate({ path: 'tag' })
      .sort({ createdAt: -1 }); // Example: sort by creation date
    ws.send(JSON.stringify({ type: 'INITIAL_EVENTS', payload: events }));
  } catch (error) {
    console.error("❌ Error sending initial events via WebSocket:", error);
    ws.send(JSON.stringify({ type: 'ERROR', payload: 'Failed to fetch initial events' }));
  }

  ws.on('message', (message) => {
    console.log('Received WebSocket message:', message.toString());
    // You can handle incoming messages from clients here if needed
    // e.g., if a client pings or requests specific data
    try {
        const parsedMessage = JSON.parse(message.toString());
        // Process parsedMessage (e.g., based on parsedMessage.type)
      } catch (e) {
        console.warn('Received non-JSON message or parse error on WebSocket:', message.toString());
      }
  });

  ws.on('close', () => {
    console.log('💔 Client disconnected from WebSocket');
    clients.delete(ws);
  });

  ws.on('error', (error) => {
    console.error('WebSocket error on client connection:', error);
    clients.delete(ws); // Ensure client is removed on error
  });
});
// --- End WebSocket Setup ---


// Basic route
app.get('/', (req, res) => {
    res.send('Backend is running.. with WebSocket support!');
});

app.get('/hello', (req, res) => {
    res.send('Hello from server');
});

// Auth routes
app.use("/api/auth", authRoutes);
app.use("/api/user", userRoutes);
app.use("/api/clubs", clubRoutes);
app.use("/api/contest", contestRoutes);
app.use('/api/acadcal', acadRoutes);
app.use("/api/tags", tagRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/onedrive", onedriveRoutes);

// Calendar routes (These seem to be direct controller calls, not router modules)
app.get('/user/:outlookId/events/:date', CalendarController.getUserEvents);
app.post('/user/:outlookId/reminder', CalendarController.setPersonalReminderTime);

// Event routes
app.use("/api/events", eventRoutes); // This router will need to import `broadcast`

// Other routes
app.use("/api/firebase", firebaseRoutes);
app.use("/api/payments", paymentRoutes);
app.use("/api/notif", notifRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Global server error:', err.stack || err); // Log stack for better debugging
    res.status(err.status || 500).json({
        status: 'error',
        message: err.message || 'Internal Server Error',
    });
});

app.get("/get-service-account", (req, res) => {
  try {
    const serviceAccountEnv = process.env.FIREBASE_SERVICE_ACCOUNT;
    if (!serviceAccountEnv) {
        console.error("FIREBASE_SERVICE_ACCOUNT environment variable is not set.");
        return res.status(500).json({ error: "Firebase service account configuration is missing." });
    }
    const serviceAccount = JSON.parse(serviceAccountEnv);
    res.json({ client_email: serviceAccount.client_email, project_id: serviceAccount.project_id , private_key: serviceAccount.private_key});
  } catch (error) {
    console.error("Error loading or parsing service account:", error);
    res.status(500).json({ error: "Failed to load or parse Firebase credentials" });
  }
});

// --- Mock cron job functions (replace with your actual implementations) ---
const fetchAndAddContests = async () => { console.log("Mock: Fetching and adding contests...")};
const removeFinishedContests = async () => { console.log("Mock: Removing finished contests...")};
// --- End mock cron job functions ---

// Schedule to run every 12 hrs, will fetch cf contests
cron.schedule('0 */12 * * *', () => {
    console.log('🕒 Cron job: Fetching Codeforces contests...');
    fetchAndAddContests();
    removeFinishedContests();
});

// Start the server using the http server instance
server.listen(PORT, '0.0.0.0', () => { // Use server.listen instead of app.listen
    console.log(` HTTP and WebSocket Server running on port ${PORT}`);
});

