// routes/onedriveRoutes.js
import express from "express";
import {
    uploadToOneDrive,
    uploadMiddleware,
    listOneDriveFiles,
    downloadOneDriveFile
} from "../modules/onedrive/onedriveController.js";

const router = express.Router();

router.post("/upload", uploadMiddleware, uploadToOneDrive);
router.get("/list", listOneDriveFiles);
router.get("/download/:clubId/:fileName", downloadOneDriveFile);

export default router;
