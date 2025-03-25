import mongoose from "mongoose";

const tagSchema = new mongoose.Schema({
  title: { type: String, required: true },
  events: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Event' }],
  createdAt: { type: Date, default: Date.now },
  users: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  clubs: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Club' }]
});

const Tag = mongoose.model("Tag", tagSchema);

export default Tag;