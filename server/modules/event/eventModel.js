import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
    // Define your schema fields here
    outlookId: { type: String, required: true },
    startTime: { type: Date, required: true },
    reminderTime: { type: Date, required: true },
    // Add other fields as necessary
});

const EventModel = mongoose.model('Event', eventSchema);

export default EventModel;  // Use default export
