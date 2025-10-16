import { Router } from "express";
import {
    getUser,
    createUser,
    updateUserController,
    selectTags,
    deleteUserTags,
    getUserFollowedEvents,
    getUserWithEmail,
    followClub,
    unfollowClub,
    getSubscribedClubs,
    getBasicAllClubs
} from "./user.controller.js";
import catchAsync from "../../utils/catchAsync.js";
import { validateUser } from "./user.model.js";
import isAuthenticated from "../../middleware/isAuthenticated.js";

const router = Router();

const validate = (schema) => {
    return (req, res, next) => {
        const { error } = schema(req.body);
        if (error) {
            return res.status(400).json({ error: error.details[0].message });
        }
        next();
    };
};

// Specific routes
router.get("/", isAuthenticated, catchAsync(getUser));
router.get("/get-user-followed-events", isAuthenticated, getUserFollowedEvents);
router.get("/subscribed/:userId", getSubscribedClubs);
router.get("/getbasicallclubs", getBasicAllClubs);

// Tag-related
router.post("/:email/tags/select", isAuthenticated, catchAsync(selectTags));
router.delete("/:email/tags/delete", isAuthenticated, catchAsync(deleteUserTags));

// Follow/unfollow
router.post("/follow", followClub);
router.delete("/unfollow", unfollowClub);

// Create / update user
router.post("/", validate(validateUser), catchAsync(createUser));
router.put("/:email", isAuthenticated, catchAsync(updateUserController));

//email
router.get("/:email", getUserWithEmail);

export default router;
