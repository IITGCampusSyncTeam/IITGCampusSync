import express from 'express';
const router = express.Router();
import { getContestList , fetchAndAddContests, removeFinishedContests} from './controller.js';  // Assuming you are using named export in controller.js

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

//route to manually fetch and delete finished contests
router.post('/remove-finished-contests', async(req,res)=>{
try{
await removeFinishedContests();
res.status(200).json({success:true, message:'finished contests removed successfully'});
}
catch(e){
res.status(500).json({success:false,error: e.message});
}
});


export default router;
