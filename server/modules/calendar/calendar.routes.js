import express from "express";
import {
  getGoogleOAuthURLController,
  googleCallbackController,
  addEventToGoogleCalendar
} from "../controllers/googleCalendarController.js";

const router = express.Router();

router.get("/auth-url", getGoogleOAuthURLController);
router.get("/callback", googleCallbackController);
router.post("/add-event", addEventToGoogleCalendar);

export default router;
