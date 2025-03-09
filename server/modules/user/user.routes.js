import { Router } from "express";
import {
    createUser,
    getUserData,
    updateUser,
    deleteUser,
    
} from './user.controller.js'; // Import the controllers
import isAuthenticated from "../../middleware/authenticateJWT.js"; // JWT auth middleware
//import validate from "../../utils/validator.js"; // Validator for request body validation
i//mport { validateUser } from './user.model.js'; // Validation schema for user

const router = Router();

// Create a new user
router.post("/", validate(validateUser), createUserController);

// Get user by ID (protected)
router.get("/:id", isAuthenticated, getUserController);

// Update user (protected)
router.put("/:id", isAuthenticated, updateUserController);

// Delete user by ID (protected)
router.delete("/:id", isAuthenticated, deleteUserController);

// Find user by email
router.get("/email/:email", findUserByEmailController);

// Get user data from Microsoft token (e.g., OAuth)
router.post("/token", getUserFromTokenController);

export default router;
