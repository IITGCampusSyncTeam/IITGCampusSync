import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  event: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event' // Reference to the event for which the notification is sent
  },
  recipients: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User' // Array of users receiving the notification
    }
  ],
  status: {
    type: String,
    enum: ['pending', 'sent', 'failed'],
    default: 'pending'
  },
  scheduledTime: {
    type: Date, // Time when the notification is scheduled to be sent
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const NotificationModel = mongoose.model('Notification', notificationSchema);

export default NotificationModel;
