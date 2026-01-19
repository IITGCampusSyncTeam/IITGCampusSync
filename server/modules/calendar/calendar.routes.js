import express from "express";
import { 
  getGoogleOAuthURLController, 
  saveGoogleTokensController, 
  linkEventToGoogleController
} from "./calendarController.js";

const router = express.Router();

//Get OAuth URL
router.get("/google/oauth/url", getGoogleOAuthURLController);

//Google OAuth callback
router.get("/google/oauth/callback", saveGoogleTokensController);

//Link an event to Google Calendar
router.post("/link/:userId/:eventId", linkEventToGoogleController);

export default router;
