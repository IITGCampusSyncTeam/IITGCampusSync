import express from 'express';
const router = express.Router();
import { getContestList } from './controller.js';  // Assuming you are using named export in controller.js

router.get('/list', getContestList);

export default router;
