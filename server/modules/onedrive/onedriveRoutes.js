import express from "express";
import { 
    uploadMiddleware,
    uploadToOneDrive,
    listClubFiles, 
    downloadClubFile,
    getOneDriveStorageInfo,
    deleteClubFile
} from "../onedrive/onedriveController.js";
import isAuthenticated from "../../middleware/isAuthenticated.js";

const router = express.Router();

// Unified file upload endpoint - handles both single and multiple files
router.post('/upload', uploadMiddleware, uploadToOneDrive);

// List files
router.get('/list', listClubFiles);

// Download file
router.get('/download/:fileId', downloadClubFile);

// Get storage info
router.get('/storage-info', getOneDriveStorageInfo);

// Delete file
router.delete('/file/:fileId', isAuthenticated, deleteClubFile);

export default router;
