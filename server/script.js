import mongoose from "mongoose";
import Event from "./modules/event/eventModel.js"; // Adjust the path as needed
import dotenv from "dotenv";
dotenv.config(); // Load environment variables
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

async function deleteAllEvents() {
    try {
        const result = await Event.deleteMany({});
        console.log(`Deleted ${result.deletedCount} events.`);
    } catch (error) {
        console.error("Error deleting events:", error);
    } finally {
        mongoose.connection.close();
    }
}

deleteAllEvents();