import { Router } from "express";
import {
    getUser,
    createUser,
    updateUserController,
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

export default router;
