// routes/onedriveRoutes.js
import express from "express";
import {
    uploadToOneDrive,
    uploadMiddleware,
    listClubFiles,        // ✅ updated to use correct controller name
    downloadClubFile      // ✅ updated to use correct controller name
} from "../onedrive/onedriveController.js";

const router = express.Router();

// 📤 Upload a file to OneDrive and store metadata
router.post("/upload", uploadMiddleware, uploadToOneDrive);

// 📄 List all files for a given club
router.get("/club-files", listClubFiles);

// 🔽 Download a file by its file document ID
router.get("/download/:fileId", downloadClubFile);

export default router;
