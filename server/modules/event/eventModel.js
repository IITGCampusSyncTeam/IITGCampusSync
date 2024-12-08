import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  title: String,
  description: String,
  dateTime: Date,
  club: { type: mongoose.Schema.Types.ObjectId, ref: 'Club' },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  feedbacks: [String],
  notifications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Notification' }],
});


const EventModel = mongoose.model('Event', eventSchema);

export default EventModel;  // Use default export
