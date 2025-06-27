import mongoose from 'mongoose';

const Schema = mongoose.Schema;

// Merch schema (sub-document)
const merchSchema = new Schema({
    name: { type: String, required: true },
    description: { type: String, required: true },
    image: { type: String, required: true }, // URL or file path of the image
    price: { type: Number, required: true },
    sizes: [{ type: String, required: true }], // Array of available sizes
    type: { 
        type: String, 
        enum: ['Normal T-Shirt', 'Oversized', 'Hoodie'], 
        required: true 
    },
    orders: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Order' }]
},{ _id: true });;

// Club schema
const clubSchema = new Schema({
    name: { type: String, unique: true, required: true },
    email: { type: String, unique: true, require: true },
    description: { type: String, required: true }, 
    secretary : { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Club secretary (user)
    members: [
        {
            userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
            responsibility: { type: String }
        }
    ],
    events: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Event' }], // Associated events
    images: { type: String }, // Club image
    websiteLink: { type: String }, // Club website
    merch: [merchSchema], // Array of merch items
    files: [{ type: mongoose.Schema.Types.ObjectId, ref: 'File' }], // Associated files
    followers:[{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],

    tag: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Tag' }], 

});

const Club = mongoose.model('Club', clubSchema);
export default Club;

export const findClubWithEmail = async (email) => {
    const club = await Club.findOne({ email });
    console.log("found club with email", club);
    return club || false;
}
