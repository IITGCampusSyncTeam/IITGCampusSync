import express from 'express';
import { 
    createClub, 
    addMerch,
    deleteMerch,
    editClub, 
    deleteClub, 
    addFeedback, 
    changeAuthority, 
    getClubs,   
    getClubDetail,
    addTagToClub,
    removeTagFromClub,
    followClub,
    addOrEditMember,
    removeMember
} from './clubController.js';
import isAuthenticated from '../../middleware/isAuthenticated.js';

const router = express.Router();

router.post('/create', createClub);
router.post("/:clubId/merch", isAuthenticated, addMerch);
router.delete("/:clubId/merch/:merchId", isAuthenticated, deleteMerch);
router.put('/edit/:id', editClub);
router.delete('/delete/:id', deleteClub);
router.post('/:id/feedback', addFeedback);
router.put('/:id/authority', changeAuthority);
router.get('/', getClubs);
router.get('/:id', getClubDetail);
router.post("/:clubId/addtag/:tagId", isAuthenticated, addTagToClub);

router.post("/:clubId/follow", isAuthenticated, followClub);

// ✅ Remove Tag from Club
router.delete("/:clubId/deletetag/:tagId", isAuthenticated, removeTagFromClub);

// ✅ New member routes
router.put('/:clubId/addmember/:email', isAuthenticated, addOrEditMember);
router.delete('/:clubId/removemember/:email', isAuthenticated, removeMember);

export default router;
