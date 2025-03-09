import mongoose from 'mongoose';
const Schema = mongoose.Schema;

const clubSchema = new Schema({
    name: { type: String, unique: true, required: true },
    description: { type: String, required: true },
    heads: [{ type: String, ref: 'User' }],
    members: [
        {
            userId: { type: String, ref: 'User' },
            responsibility: { type: String }
        }
    ],
    events: [{ type: String, ref: 'Event' }],
    images: { type: String },
    websiteLink: { type: String }
});

const Club = mongoose.model('Club', clubSchema);
export default Club;