import express from 'express';
import { 
    createClub, 
    editClub, 
    deleteClub, 
    addFeedback, 
    changeAuthority, 
    getClubs,   
    getClubDetail  
} from './clubController.js';

const router = express.Router();

router.post('/create', createClub);
router.put('/edit/:id', editClub);
router.delete('/delete/:id', deleteClub);
router.post('/:id/feedback', addFeedback);
router.put('/:id/authority', changeAuthority);
router.get('/', getClubs);
router.get('/:id', getClubDetail);

export default router;
