import { Router } from "express";
import {
    getUser,
    createUser,
    updateUserController,
    
} from "./user.controller.js";
import catchAsync from "../../utils/catchAsync.js";
const router = Router();
import validate from "../../utils/validator.js";
import { validateUser } from "./user.model.js";

import isAuthenticated from "../../middleware/isAuthenticated.js";

router.get("/", isAuthenticated, catchAsync(getUser));

//not used
router.post("/", validate(validateUser), catchAsync(createUser));
router.put("/update", isAuthenticated, catchAsync(updateUserController));

export default router;