import mongoose from 'mongoose';
<<<<<<< HEAD
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
=======

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
    description: { type: String, required: true }, 
    secretary : { type: mongoose.Schema.Types.ObjectId, ref: 'User' }, // Club secretary (user)
    heads: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // Club heads (users)
    members: [
        {
            userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
            responsibility: { type: String }
        }
    ],
    events: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Event' }], // Associated events
    images: { type: String }, // Club image
    websiteLink: { type: String }, // Club website
    merch: [merchSchema] // Array of merch items
});

const Club = mongoose.model('Club', clubSchema);
export default Club;
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
