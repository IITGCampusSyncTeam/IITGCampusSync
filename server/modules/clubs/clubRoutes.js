import express from 'express';
import { createClub, editClub, deleteClub, addFeedback, changeAuthority } from './clubController.js';

const router = express.Router();

router.post('/create', createClub);
router.put('/edit/:id', editClub);
router.delete('/delete/:id', deleteClub);
router.post('/:id/feedback', addFeedback);
router.put('/:id/authority', changeAuthority);

export default router;
