import { Router } from "express";
import {
    getUser,
    createUser,
    updateUserController,
    selectTag,
    deleteUserTag,
    getUserFollowedEvents
} from "./user.controller.js";
import catchAsync from "../../utils/catchAsync.js";
import { validateUser } from "./user.model.js";
import isAuthenticated from "../../middleware/isAuthenticated.js";

const router = Router();

// Validation middleware
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

// Apply validation middleware
router.post("/", validate(validateUser), catchAsync(createUser));
router.put("/:email", isAuthenticated, catchAsync(updateUserController));
//TODO HAVE TO CHECK THE API BELOW
router.get("/get-user-followed-events",isAuthenticated,getUserFollowedEvents);
// New routes for selecting and deleting user tags
router.post("/:email/addtag/:tagId", isAuthenticated, catchAsync(selectTag)); // Add a tag
router.delete("/:email/deletetag/:tagId", isAuthenticated, catchAsync(deleteUserTag)); // Remove a tag
export default router;
