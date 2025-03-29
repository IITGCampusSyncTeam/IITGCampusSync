import mongoose from "mongoose";

const fileSchema = new mongoose.Schema({
  name: { type: String, required: true },
  mimeType: String,
  size: Number,
  link: { type: String, required: true }, // Public shareable link

  category: {
    type: String,
    enum: ["club", "event"],
    required: true,
  },
  referenceId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    refPath: "category",
  },

  uploadedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  uploadedAt: {
    type: Date,
    default: Date.now,
  },
  visibility: {
    type: String,
    enum: ["public", "private"],
    default: "private", // Set default visibility to private
    required: true
  },

});

export default mongoose.model("File", fileSchema);
