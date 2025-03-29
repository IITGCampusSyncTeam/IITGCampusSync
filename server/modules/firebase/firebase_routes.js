import express from 'express';
import { saveFcmToken, getFcmTokens } from './firebase_controller.js';

const router = express.Router();

router.post('/save-token', saveFcmToken);
router.get('/get-tokens', getFcmTokens);

export default router;