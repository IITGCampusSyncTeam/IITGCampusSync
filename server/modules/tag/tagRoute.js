import express from "express";
import {
    getAllTags,
    addTags,
    deleteTags,
    updateUserTags,
    getUserTags,
} from "./tagController.js";

const router = express.Router();

router.get("/", getAllTags);
router.post("/add", addTags);
router.delete("/delete", deleteTags);
router.put("/updateUserTags", updateUserTags);
router.get("/user/:email", getUserTags);

export default router;
