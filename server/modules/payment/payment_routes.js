import express from 'express';
import { createOrder, verifyPayment, getRazorpayKey } from './payment_controller.js';

const router = express.Router();

router.post('/create-order', createOrder);
router.post('/verify-payment', verifyPayment);
router.get('/get-razorpay-key', getRazorpayKey);

export default router;