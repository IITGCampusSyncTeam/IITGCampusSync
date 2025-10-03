import express from "express";
import { 
  getGoogleOAuthURLController, 
  saveGoogleTokensController, 
  linkEventToGoogleController 
} from "./calendarController.js";

const router = express.Router();

// OAuth routes
router.get("/google/oauth/url", getGoogleOAuthURLController);
router.get("/google/oauth/callback/:userId", saveGoogleTokensController);

// Link event
router.post("/link/:userId/:eventId", linkEventToGoogleController);