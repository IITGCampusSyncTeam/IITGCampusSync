import express from 'express';
import { saveFcmToken, getFcmTokens } from './firebaseController.js';

const router = express.Router();

router.post('/save-token', saveFcmToken);
router.get('/get-tokens', getFcmTokens);

export default router;
