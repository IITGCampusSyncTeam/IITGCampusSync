import Razorpay from "razorpay";
import crypto from "crypto";

const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET,
});

//for sending key to frontend
export const getRazorpayKey = (req, res) => {
    try {
        res.json({ key: process.env.RAZORPAY_KEY_ID });
    } catch (error) {
        console.error("Error fetching Razorpay key:", error);
        res.status(500).json({ error: "Internal server error" });
    }
};

// Create order
export const createOrder = async (req, res) => {
    try {
        const options = { amount: req.body.amount * 100, currency: "INR", receipt: "order_rcptid_11" };
        const order = await razorpay.orders.create(options);
        res.json(order);
    } catch (error) {
        res.status(500).send(error);
    }
};

// Verify payment
export const verifyPayment = async (req, res) => {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;
    const generated_signature = crypto.createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
        .update(`${razorpay_order_id}|${razorpay_payment_id}`)
        .digest("hex");

    if (generated_signature === razorpay_signature) {
        res.json({ success: true, message: "Payment verified successfully" });
    } else {
        res.status(400).json({ success: false, message: "Payment verification failed" });
    }
};