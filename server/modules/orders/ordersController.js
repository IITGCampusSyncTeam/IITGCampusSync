import Order from "./ordersModel.js";
import Club from "../club/clubModel.js";
import User from "../user/user.model.js";


export const createOrder = async (req, res) => {
    try {
        const { user, name, contact, hostel, roomNum, items, totalPrice } = req.body;

        // Ensure required fields are provided
        if (!user || !name || !contact || !hostel || !roomNum || !items || !Array.isArray(items) || items.length === 0) {
            return res.status(400).json({
                success: false,
                message: "All user details and at least one item are required.",
            });
        }

        // Validate each item in the order
        for (const item of items) {
            if (!item.merchId || !item.size || !item.quantity) {
                return res.status(400).json({
                    success: false,
                    message: "Each item must have merchId, size, and quantity.",
                });
            }

            //  Fetch the club that contains this merch item
            const clubWithMerch = await Club.findOne({ "merch._id": item.merchId });

            if (!clubWithMerch) {
                return res.status(404).json({
                    success: false,
                    message: `Merch item with ID ${item.merchId} not found in any club.`,
                });
            }

            // Extract the specific merch item
            const merchItem = clubWithMerch.merch.find(m => m._id.toString() === item.merchId);

            if (!merchItem) {
                return res.status(404).json({
                    success: false,
                    message: `Merch item with ID ${item.merchId} not found.`,
                });
            }
        }

        //  Create orders for each unique merchId and size
        const orders = await Order.insertMany(
            items.map(item => ({
                user,
                merch: item.merchId,
                quantity: item.quantity,
                size: item.size,
                totalPrice, // Already calculated in frontend
                name,
                contact,
                hostel,
                roomNum,
                orderedAt: new Date(),
            }))
        );

        //  Extract all order IDs
        const orderIds = orders.map(order => order._id);

        //  Update merch orders in the Club collection
        for (const item of items) {
            await Club.updateOne(
                { "merch._id": item.merchId },
                { $push: { "merch.$.orders": { $each: orderIds } } }
            );
        }

        //  Add order IDs to the user's merchOrders array
        await User.findByIdAndUpdate(user, { $push: { merchOrders: { $each: orderIds } } });

        res.status(201).json({
            success: true,
            message: "Order created successfully",
            orders,
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Error creating order",
            error: error.message,
        });
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
        
        // Fetch all orders by user
        const orders = await Order.find({ user: userId }).lean();

        // Populate merch details from Club model
        for (const order of orders) {
            const clubWithMerch = await Club.findOne({ "merch._id": order.merch });

            if (clubWithMerch) {
                const merchItem = clubWithMerch.merch.find(m => m._id.toString() === order.merch.toString());
                order.merchDetails = merchItem; // Attach merch details to response
            }
        }

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

// UPDATE ORDER (e.g., update quantity, size, or user details)
export const updateOrder = async (req, res) => {
    try {
        const { orderId } = req.params;
        const updates = req.body;

        // Prevent removing required fields
        if (updates.name === "" || updates.contact === "" || updates.hostel === "" || updates.roomNum === "") {
            return res.status(400).json({ success: false, message: "User details cannot be empty." });
        }

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
