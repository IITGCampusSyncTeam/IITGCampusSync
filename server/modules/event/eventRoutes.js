import express from 'express';
import eventController from '../controllers/eventController.js';
import isAuthenticated from '../../middleware/isAuthenticated.js';

const router = express.Router();

// Event routes
router.post('/create', eventController.createEvent);  // Create a new event
router.get('/all', eventController.getEvents);  // Get all events
router.get('/upcoming', eventController.getUpcomingEvents);  // Get upcoming events
router.get('/followed/:userId', isAuthenticated, eventController.getFollowedClubEvents); // Get events of followed clubs
router.get('/myinterest/:userId', isAuthenticated, eventController.getInterestEvents); // Get events based on user interests

export default router;
