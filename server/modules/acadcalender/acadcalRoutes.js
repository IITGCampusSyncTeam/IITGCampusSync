import express from "express";
import { getAllacadEvents, addacadEvent, deleteAllacadEvents } from "./acadcalController.js";

const router = express.Router();

router.get("/", getAllacadEvents); // Get all events
router.post("/add",addacadEvent); // Add a new event
router.delete("/delete", deleteAllacadEvents); // Delete all events

export default router;
