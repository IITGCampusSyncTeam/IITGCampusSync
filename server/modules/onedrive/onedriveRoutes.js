// modules/onedrive/onedriveRoutes.js

import express from 'express';
import multer from 'multer';
import { uploadToOneDrive, listOneDriveFiles, downloadOneDriveFile } from './onedriveController.js';

const router = express.Router();
const upload = multer(); // memory storage

// Upload a file to OneDrive
router.post('/upload', upload.single('file'), uploadToOneDrive);

// List files from club's OneDrive folder
router.get('/files', listOneDriveFiles);

// Download file by OneDrive item ID
router.get('/download/:id', downloadOneDriveFile);

export default router;
