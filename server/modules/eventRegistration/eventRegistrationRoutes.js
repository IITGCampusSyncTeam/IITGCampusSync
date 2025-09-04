import express from 'express';
import eventRegistrationController from './eventRegistrationController.js';
import isAuthenticated from '../../middleware/isAuthenticated.js'; // Your auth middleware

const router = express.Router();


router.use(isAuthenticated);

// POST /api/v1/registrations/events/EVENT_ID/rsvp
router.post('/events/:eventId/rsvp', eventRegistrationController.toggleRsvp);

// GET /api/v1/registrations/events/EVENT_ID
router.get('/events/:eventId', eventRegistrationController.getRegistrationsForEvent);

export default router;