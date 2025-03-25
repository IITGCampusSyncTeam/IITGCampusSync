import express from 'express';
const router = express.Router();
import { getContestList , fetchAndAddContests} from './controller.js';  // Assuming you are using named export in controller.js

router.get('/list', getContestList);
// Route to manually fetch and add contests
router.post('/fetch-contests', async (req, res) => {
    try {
        await fetchAndAddContests();
        res.status(200).json({ success: true, message: 'Contests fetched and added successfully' });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});


export default router;
