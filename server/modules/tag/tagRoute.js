import express from "express";
import { getAllTags, addTag, deleteTag } from "./tagController.js";

const router = express.Router();

router.get("/", getAllTags);     // Get all tags
router.post("/add", addTag);        // Add a new tag
router.delete("/delete", deleteTag); // Delete a tag by ID

export default router;
