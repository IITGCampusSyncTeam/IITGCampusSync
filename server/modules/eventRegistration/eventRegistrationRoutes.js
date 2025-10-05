import express from 'express';
import isAuthenticated from '../../middleware/isAuthenticated.js'; // Your auth middleware

import { toggleRsvp, getRegistrationsForEvent } from './eventRegistrationController.js';
const router = express.Router();


router.use(isAuthenticated);

// POST /api/v1/registrations/events/EVENT_ID/rsvp
router.post('/events/:eventId/rsvp',toggleRsvp);

// GET /api/v1/registrations/events/EVENT_ID
router.get('/events/:eventId', getRegistrationsForEvent);

export default router;