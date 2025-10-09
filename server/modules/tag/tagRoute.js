import express from "express";
import { getAllTags, addTags, deleteTags, updateUserTags } from "./tagController.js";

const router = express.Router();

router.get("/", getAllTags);
router.post("/add", addTags);
router.delete("/delete", deleteTags);
router.put("/updateUserTags", updateUserTags);

export default router;
