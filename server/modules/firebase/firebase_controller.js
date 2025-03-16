import admin from 'firebase-admin';
import User from '../user/user.model.js';

// Initialize Firebase
try {
    const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);

    // Ensure private key is properly formatted
    serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');

    admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
    console.log(' Firebase Admin SDK initialized successfully.');
} catch (error) {
    console.error(' Error initializing Firebase Admin SDK:', error);
    process.exit(1);
}
export {admin} ;
// Save FCM token
export const saveFcmToken = async (req, res) => {
    const { email, fcmToken } = req.body;
console.log('Incoming Data:', req.body);
    if (!email || !fcmToken) {
        return res.status(400).json({ error: "Email and FCM token are required" });
    }

    try {
        const user = await User.findOneAndUpdate(
            { email },
            { fcmToken },  // Directly update the token
            { new: true }  // Return the updated user document
        );

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.status(200).json({ message: '✅ FCM token updated successfully' });
    } catch (err) {
        console.error('❌ Error updating FCM token:', err);
        res.status(500).json({ error: 'Internal server error' });
    }
};


// Get all FCM tokens
export const getFcmTokens = async (req, res) => {
    try {
        const users = await User.find({});
        const tokens = users.map(user => user.fcmToken).filter(Boolean);
        res.json(tokens);
    } catch (error) {
        console.error('Error fetching tokens:', error);
        res.status(500).json({ error: 'Internal Server Error' });
    }
};