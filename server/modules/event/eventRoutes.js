import express from "express";
import eventController from "./eventController.js";

const router = express.Router();

// Define routes for event-related operations
router.post("/create-event", eventController.createEvent); // Route to create an event
router.get("/get-all-events", eventController.getEvents); // Route to get all events
router.get("/get-upcoming-events", eventController.getUpcomingEvents); // Route to get upcoming events
router.get("/past/:clubId", eventController.getPastEventsOfClub); // Past events for a club
router.get("/followed/:userId", eventController.getFollowedClubEvents); // Events from followed clubs
router.put("/status/:eventId", eventController.updateEventStatus); // Update event status
router.put("/edit/:eventId", eventController.editEvent); // Edit event info
router.post('/tentative', eventController.createTentativeEvent);// add tentative event

export default router;
