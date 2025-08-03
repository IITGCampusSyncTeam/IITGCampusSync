import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  title: String,
  description: String,
  dateTime: Date,
  venue: String,
  club: { type: mongoose.Schema.Types.ObjectId, ref: 'Club' },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  feedbacks: [String],
  notifications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Notification' }],
  tag: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Tag' }],
  status: {
      type: String,
      enum: ['drafted', 'tentative', 'published'],
      default: 'drafted',
    },
});


const EventModel = mongoose.model('Event', eventSchema);

export default EventModel;  // Use default export
