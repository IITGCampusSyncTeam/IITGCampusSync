import express from "express";
import isAuthenticated from "../../middleware/isAuthenticated.js";


// ✅ Import ALL the functions you need in one single, named import
import {
  createEvent,
  getEvents,
  getUpcomingEvents,
  getPastEventsOfClub,
  getFollowedClubEvents,
  getCreatorEvents,
  getRsvpdUpcomingEvents,
  getAttendedEvents,
  updateEventStatus,
  editEvent,
  createTentativeEvent,
  rsvpToEvent,
  getEventRSVPs,
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
router.get("/active-events-by-creator/:createdBy", getCreatorEvents); // Route to get all active events by a particular creator
router.put("/status/:eventId", updateEventStatus);
router.put("/edit/:eventId", editEvent);
router.post('/tentative', createTentativeEvent);
router.post('/rsvp/:eventId', rsvpToEvent); // RSVP to an event
router.get('/rsvp/:eventId', getEventRSVPs); // Get RSVP list for an event

export default router;
