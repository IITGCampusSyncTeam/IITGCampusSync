import express from "express";
import { getAllTags, addTags, deleteTags } from "./tagController.js";

const router = express.Router();

router.get("/", getAllTags);
router.post("/add", addTags);
router.delete("/delete", deleteTags);

export default router;