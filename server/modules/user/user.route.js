import { Router } from "express";
import {
    getUser,
    createUser,
    updateUserController,
    selectTags,
    deleteUserTags,
    getUserFollowedEvents,
    getUserWithEmail,
    getUserProfile
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

router.get("/", isAuthenticated, catchAsync(getUser));
router.get("/:email", getUserWithEmail);
router.post("/", validate(validateUser), catchAsync(createUser));
router.put("/:email", isAuthenticated, catchAsync(updateUserController));
router.get("/get-user-followed-events", isAuthenticated, getUserFollowedEvents);
router.get("/get-profile/:userID", isAuthenticated, getUserProfile);
router.post("/:email/tags/select", isAuthenticated, catchAsync(selectTags));
router.delete("/:email/tags/delete", isAuthenticated, catchAsync(deleteUserTags));

export default router;