import mongoose from 'mongoose';

const eventSchema = new mongoose.Schema({
  title: String,
  description: String,
  banner: String,
  dateTime: Date,
  venue: String,
  club: { type: mongoose.Schema.Types.ObjectId, ref: 'Club' },
  views: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  RSVP: [
    {
      user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
      status: { type: String, enum: ['yes', 'no', 'maybe'], default: 'yes' },
      timestamp: { type: Date, default: Date.now }
    }
  ],
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  feedbacks: [String],
  notifications: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Notification' }],
  tag: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Tag' }],
  status: {
      type: String,
      enum: ['drafted', 'tentative', 'published', 'live', 'finished'],
      default: 'drafted',
    },
});


const EventModel = mongoose.model('Event', eventSchema);

export default EventModel;  // Use default export
