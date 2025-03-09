import mongoose from "mongoose";

const acadcalSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  category: { type: String, required: true },
  applicableTo: { type: [String], required: true }, // Example: ["BTech", "MTech", "PhD"]
  important: { type: Boolean, default: false },
  location: { type: String },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

const Acadcal = mongoose.model("Acadcal", acadcalSchema);

export default Acadcal;
