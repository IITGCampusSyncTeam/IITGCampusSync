import express from 'express';
import { createClub} from './clubController.js'; // Example

const router = express.Router();

router.post('/create', createClub);
// router.put('/edit/:id', editClub);
// router.delete('/delete/:id', deleteClub);
// router.post('/feedback', addFeedback);
// router.put('/authority', changeAuthority);

export default router; // Default export
