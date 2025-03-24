import cron from 'node-cron';
import { fetchAndAddContests } from './contestController.js';

// Schedule to run at 2 AM every night
cron.schedule('0 2 * * *', () => {
    console.log('Fetching Codeforces contests...');
    fetchAndAddContests();
});
