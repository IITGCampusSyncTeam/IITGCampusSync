import express from 'express';
<<<<<<< HEAD
import { createClub, editClub, deleteClub, addFeedback, changeAuthority } from './clubController.js';
=======
import { 
    createClub, 
    addMerch,
    deleteMerch,
    editClub, 
    deleteClub, 
    addFeedback, 
    changeAuthority, 
    getClubs,   
    getClubDetail
} from './clubController.js';
import isAuthenticated from '../../middleware/isAuthenticated.js';
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050

const router = express.Router();

router.post('/create', createClub);
<<<<<<< HEAD
=======
router.post("/:clubId/merch", isAuthenticated, addMerch);
router.delete("/:clubId/merch/:merchId", isAuthenticated, deleteMerch);
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
router.put('/edit/:id', editClub);
router.delete('/delete/:id', deleteClub);
router.post('/:id/feedback', addFeedback);
router.put('/:id/authority', changeAuthority);
<<<<<<< HEAD

export default router;
=======
router.get('/', getClubs);
router.get('/:id', getClubDetail);

export default router;
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
