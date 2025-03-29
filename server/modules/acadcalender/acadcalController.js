import Acadcal from "./acadcalModel.js";

// @desc Get all events
export const getAllacadEvents = async (req, res) => {
  try {
    const events = await Acadcal.find();
    res.status(200).json(events);
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};

// @desc Add a new event
export const addacadEvent = async (req, res) => {
  try {
    const event = new Acadcal(req.body);
    await event.save();
    res.status(201).json(event);
  } catch (error) {
    res.status(400).json({ message: "Error adding event", error });
  }
};

// @desc Delete all events
export const deleteAllacadEvents = async (req, res) => {
  try {
    await Acadcal.deleteMany();
    res.status(200).json({ message: "All events deleted" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting events", error });
  }
};
