const mongoose = require('mongoose');

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

const Event = mongoose.model('Event', eventSchema);
module.exports = Event;