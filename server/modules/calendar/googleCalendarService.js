import { google } from "googleapis";
import dotenv from "dotenv";
import User from "../user/userModel.js";

dotenv.config();

const { GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI } = process.env;

const oAuth2Client = new google.auth.OAuth2(
  GOOGLE_CLIENT_ID,
  GOOGLE_CLIENT_SECRET,
  GOOGLE_REDIRECT_URI
);

// Generate OAuth URL
export const getGoogleAuthURL = () => {
  const scopes = [
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/calendar.events",
  ];
  return oAuth2Client.generateAuthUrl({
    access_type: "offline",
    scope: scopes,
    prompt: "consent",
  });
};

// Exchange auth code for tokens
export const getTokensFromCode = async (code) => {
  const { tokens } = await oAuth2Client.getToken(code);
  return tokens;
};

// Set OAuth2 client for a user
export const setUserOAuthClient = async (userId) => {
  const user = await User.findById(userId).select("+googleAccessToken +googleRefreshToken");
  if (!user || !user.googleRefreshToken) throw new Error("User not linked with Google");

  oAuth2Client.setCredentials({
    access_token: user.googleAccessToken,
    refresh_token: user.googleRefreshToken,
  });

  // Automatically refresh token
  oAuth2Client.on("tokens", (tokens) => {
    if (tokens.access_token) user.googleAccessToken = tokens.access_token;
    if (tokens.refresh_token) user.googleRefreshToken = tokens.refresh_token;
    user.save();
  });

  return oAuth2Client;
};

// creates a new event in Google Calendar from the event in the app
export const createGoogleEvent = async (userId, event) => {
  const auth = await setUserOAuthClient(userId);
  const calendar = google.calendar({ version: "v3", auth });

  const googleEvent = {
    summary: event.title,
    description: event.description,
    start: { dateTime: event.dateTime.toISOString() },
    end: { dateTime: new Date(event.dateTime.getTime() + 2 * 60 * 60 * 1000).toISOString() }, // +2 hour
  };

  const createdEvent = await calendar.events.insert({
    calendarId: "primary",
    requestBody: googleEvent,
  });

  return createdEvent.data; 
};

