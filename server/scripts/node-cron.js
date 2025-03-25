import cron from 'node-cron';
import { fetchAndAddContests } from './contestController.js';
import { checkRemindersAndSendNotifications } from '../modules/notif/notification_controller.js';

dotenv.config();

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT))
    });
}

// Schedule to run at 2 AM every night
cron.schedule('0 2 * * *', () => {
    console.log('Fetching Codeforces contests...');
    fetchAndAddContests();
});



// Schedule the reminder check to run every minute
cron.schedule('* * * * *', async () => {
    console.log('🚀 Running reminder notification script...');
    await checkRemindersAndSendNotifications();
});



