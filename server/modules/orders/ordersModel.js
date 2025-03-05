import mongoose from 'mongoose';

const Schema = mongoose.Schema;

// Order schema
const orderSchema = new Schema({
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // User who placed the order
    merch: { type: mongoose.Schema.Types.ObjectId, ref: 'Merch', required: true }, // Ordered merch item
    quantity: { type: Number, required: true, min: 1 }, // Quantity of the merch ordered
    size: { type: String, required: true }, // Selected size of merch
    totalPrice: { type: Number, required: true }, // Total price (price * quantity)
    status: { 
        type: String, 
        enum: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'], 
        default: 'Pending' 
    }, // Order status
    orderedAt: { type: Date, default: Date.now }, // Timestamp of order
});

const Order = mongoose.model('Order', orderSchema);
export default Order;
