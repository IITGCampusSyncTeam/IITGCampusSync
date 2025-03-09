import express from "express";
import {
    createOrder,
    getAllOrders,
    getOrderById,
    getOrdersByUser,
    getOrdersByMerch,
    updateOrder,
    deleteOrder
} from "./ordersController.js";

const router = express.Router();

// Create a new order
router.post("/", createOrder);

// Get all orders
router.get("/", getAllOrders);

// Get order by ID
router.get("/:orderId", getOrderById);

// Get all orders placed by a specific user
router.get("/user/:userId", getOrdersByUser);

// Get all orders for a specific merch
router.get("/merch/:merchId", getOrdersByMerch);

// Update an order (e.g., update quantity or size)
router.put("/:orderId", updateOrder);

// Delete an order
router.delete("/:orderId", deleteOrder);

export default router;
