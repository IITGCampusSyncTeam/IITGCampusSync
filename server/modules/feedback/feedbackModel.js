import mongoose from 'mongoose';

const feedbackSchema = new mongoose.Schema({
    clubId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Club', // Reference to the Club model
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User', // Reference to the User model
    },
    feedback: {
        type: String,
        required: true,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

// Create a Feedback model from the schema
const Feedback = mongoose.model('Feedback', feedbackSchema);

export default Feedback;