import express from "express";
import isAuthenticated from "../../middleware/isAuthenticated.js";
import isAuthenticated from "../../middleware/isAuthenticated.js";

// ✅ Import ALL the functions you need in one single, named import
import {
  createEvent,
  getEvents,
  getUpcomingEvents,
  getPastEventsOfClub,
  getFollowedClubEvents,
  getRsvpdUpcomingEvents,
  getAttendedEvents,
  updateEventStatus,
  editEvent,
  createTentativeEvent
} from "./eventController.js";

const router = express.Router();

// ✅ Use the functions directly, without the "eventController." prefix
router.post("/create-event", createEvent);
router.get("/get-all-events", getEvents);
router.get("/get-upcoming-events", getUpcomingEvents);
router.get("/past/:clubId", getPastEventsOfClub);
router.get("/followed/:userId", getFollowedClubEvents);
router.get("/rsvpd/upcoming", isAuthenticated, getRsvpdUpcomingEvents);
router.get("/rsvpd/attended", isAuthenticated, getAttendedEvents);
router.put("/status/:eventId", updateEventStatus);
router.put("/edit/:eventId", editEvent);
router.post('/tentative', createTentativeEvent);

export default router;
