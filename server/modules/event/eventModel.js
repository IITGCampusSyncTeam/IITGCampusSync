import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
    // Define your schema fields here
    outlookId: String,
    startTime: Date,
    reminderTime: Date,
    // Add other fields as necessary
});

const EventModel = mongoose.model('Event', eventSchema);

export default EventModel;  // Use default export
