const mongoose = require('mongoose');


// User Model (Simplified)
const userSchema = new mongoose.Schema({
  fcmToken: String,
});

const User = mongoose.model('User', userSchema);
module.exports = User;