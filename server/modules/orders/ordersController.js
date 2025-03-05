import Order from "./ordersModel.js";
import Club from "../club/clubModel.js";
import User from "../user/user.model.js";

// CREATE ORDER
export const createOrder = async (req, res) => {
    try {
        const { user, merchId, quantity, size, totalPrice } = req.body;

        // Create new order
        const newOrder = await Order.create({
            user,
            merch: merchId,
            quantity,
            size,
            totalPrice,
            orderedAt: new Date(),
        });

        // Add order ID to the corresponding merch's orders array
        await Club.updateOne(
            { "merch._id": merchId },
            { $push: { "merch.$.orders": newOrder._id } }
        );

        // Add order ID to the user's merchOrders array
        await User.findByIdAndUpdate(user, { $push: { merchOrders: newOrder._id } });

        res.status(201).json({ success: true, message: 'Order created successfully', order: newOrder });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error creating order', error: error.message });
    }
};

// GET ALL ORDERS
export const getAllOrders = async (req, res) => {
    try {
        const orders = await Order.find().populate("user merch");
        res.status(200).json({ success: true, orders });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error fetching orders', error: error.message });
    }
};

// GET ORDER BY ID
export const getOrderById = async (req, res) => {
    try {
        const { orderId } = req.params;
        const order = await Order.findById(orderId).populate("user merch");

        if (!order) {
            return res.status(404).json({ success: false, message: "Order not found" });
        }

        res.status(200).json({ success: true, order });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error fetching order', error: error.message });
    }
};

// GET ORDERS BY USER ID
export const getOrdersByUser = async (req, res) => {
    try {
        const { userId } = req.params;
        const orders = await Order.find({ user: userId }).populate("merch");

        res.status(200).json({ success: true, orders });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error fetching user orders', error: error.message });
    }
};

// GET ORDERS BY MERCH ID
export const getOrdersByMerch = async (req, res) => {
    try {
        const { merchId } = req.params;
        const orders = await Order.find({ merch: merchId }).populate("user");

        res.status(200).json({ success: true, orders });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error fetching merch orders', error: error.message });
    }
};

// UPDATE ORDER (e.g., update quantity or size)
export const updateOrder = async (req, res) => {
    try {
        const { orderId } = req.params;
        const updates = req.body;

        const updatedOrder = await Order.findByIdAndUpdate(orderId, updates, { new: true });

        if (!updatedOrder) {
            return res.status(404).json({ success: false, message: "Order not found" });
        }

        res.status(200).json({ success: true, message: "Order updated successfully", order: updatedOrder });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error updating order', error: error.message });
    }
};

// DELETE ORDER
export const deleteOrder = async (req, res) => {
    try {
        const { orderId } = req.params;

        const order = await Order.findById(orderId);
        if (!order) {
            return res.status(404).json({ success: false, message: "Order not found" });
        }

        // Remove order from user's merchOrders array
        await User.findByIdAndUpdate(order.user, { $pull: { merchOrders: orderId } });

        // Remove order from merch's orders array
        await Club.updateOne(
            { "merch._id": order.merch },
            { $pull: { "merch.$.orders": orderId } }
        );

        // Delete order
        await Order.findByIdAndDelete(orderId);

        res.status(200).json({ success: true, message: "Order deleted successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: 'Error deleting order', error: error.message });
    }
};
