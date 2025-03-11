import express from 'express';
import { createOrder, verifyPayment, getRazorpayKey } from './payment_controller.js';

const router = express.Router();

router.post('/api/payments/create-order', createOrder);
router.post('/api/payments/verify-payment', verifyPayment);
router.get('/api/payments/get-razorpay-key', getRazorpayKey);

export default router;