import axios from "axios";
import fs from "fs";
import path from "path";
import multer from "multer";
import { fileURLToPath } from "url";
import { dirname } from "path";
import catchAsync from "../../utils/catchAsync.js";
import AppError from "../../utils/appError.js";
import { getAccessTokenByEmail } from "../../utils/getAccessTokenByEmail.js";
import Club from "../club/clubModel.js";
import File from "./onedriveModel.js"; 

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const uploadDir = path.join(__dirname, "../../../uploads");

// Ensure uploads directory exists
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Configure multer storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, uniqueSuffix + "-" + file.originalname); 
    },
});

// Create a unified upload middleware
export const uploadMiddleware = multer({ storage }).any();

// Helper function to format bytes
const formatBytes = (bytes, decimals = 2) => {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB'];
    
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
};

// Main upload function that handles both single and multiple files
export const uploadToOneDrive = catchAsync(async (req, res, next) => {
    const { category, referenceId, visibility } = req.body;
    const files = req.files || [];
    const customFilenames = req.body.customFilenames ? JSON.parse(req.body.customFilenames) : [];
    
    // For single file with single customFilename string
    if (!Array.isArray(customFilenames) && req.body.customFilename) {
        customFilenames.push(req.body.customFilename);
    }

    if (files.length === 0) return next(new AppError(400, "No files uploaded"));
    if (!category || !referenceId) return next(new AppError(400, "Category and Reference ID are required"));

    // Only club supported for now
    if (category !== "club") {
        return next(new AppError(400, "Currently only 'club' category is supported"));
    }

    const club = await Club.findById(referenceId).populate("secretary");
    if (!club || !club.secretary) return next(new AppError(404, "Club or Secretary not found"));

    const accessToken = await getAccessTokenByEmail(club.secretary.email);
    if (!accessToken) return next(new AppError(403, "Access token not found"));

    // Check storage space for all files
    try {
        const driveResponse = await axios.get('https://graph.microsoft.com/v1.0/me/drive', {
            headers: { 'Authorization': `Bearer ${accessToken}` }
        });
        
        const quota = driveResponse.data.quota;
        const available = quota.total - quota.used;
        
        // Calculate total size of all files
        const totalUploadSize = files.reduce((sum, file) => sum + file.size, 0);
        
        if (available < totalUploadSize) {
            // Clean up temporary files
            files.forEach(file => {
                if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
            });
            
            return next(new AppError(507, 
                `Insufficient storage space in OneDrive. Available: ${formatBytes(available)}, Required: ${formatBytes(totalUploadSize)}`
            ));
        }
    } catch (error) {
        console.error('Error checking OneDrive space:', error);
        return next(new AppError(500, 'Failed to check OneDrive storage space'));
    }

    const uploadedFiles = [];
    const errors = [];

    // Process each file
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const customFilename = i < customFilenames.length ? customFilenames[i] : null;
        
        try {
            // Use custom filename if provided, otherwise use original filename
            const filename = customFilename || file.originalname;
            
            // Ensure the filename has the correct extension
            let finalFilename = filename;
            if (customFilename) {
                const originalExt = path.extname(file.originalname);
                const customExt = path.extname(customFilename);
                
                if (!customExt) {
                    finalFilename = `${customFilename}${originalExt}`;
                } else if (customExt.toLowerCase() !== originalExt.toLowerCase()) {
                    finalFilename = filename.replace(customExt, originalExt);
                }
            }
            
            const uploadUrl = `https://graph.microsoft.com/v1.0/me/drive/root:/iitgsync/${finalFilename}:/content`;

            // Upload file
            const fileStream = fs.createReadStream(file.path);
            const uploadRes = await axios.put(uploadUrl, fileStream, {
                headers: {
                    Authorization: `Bearer ${accessToken}`,
                    "Content-Type": file.mimetype,
                },
                maxBodyLength: Infinity,
                maxContentLength: Infinity,
                onUploadProgress: progressEvent => {
                    const percent = Math.round((progressEvent.loaded * 100) / file.size);
                    console.log(`Upload progress for ${finalFilename}: ${percent}%`);
                },
            });

            const fileId = uploadRes.data?.id;

            // Create sharing link
            const shareUrl = `https://graph.microsoft.com/v1.0/me/drive/items/${fileId}/createLink`;
            const shareRes = await axios.post(
                shareUrl,
                { type: "view", scope: "anonymous" },
                { headers: { Authorization: `Bearer ${accessToken}` } }
            );

            const downloadLink = shareRes.data?.link?.webUrl;
            
            // Validate visibility
            const validVisibility = visibility === 'public' || visibility === 'private' ? visibility : 'private';

            // Store in DB
            const savedFile = await File.create({
                category,
                referenceId,
                name: finalFilename,
                mimeType: file.mimetype,
                size: file.size,
                link: downloadLink,
                uploadedBy: club.secretary._id,
                visibility: validVisibility
            });

            // Add to club's files array
            await Club.findByIdAndUpdate(referenceId, {
                $push: { files: savedFile._id },
            });

            uploadedFiles.push(savedFile);
            
        } catch (error) {
            console.error(`Error uploading file ${file.originalname}:`, error);
            errors.push({
                fileName: file.originalname,
                error: error.message
            });
        } finally {
            // Clean up the temporary file
            if (fs.existsSync(file.path)) fs.unlinkSync(file.path);
        }
    }

    // Return appropriate response based on single or multiple files
    if (files.length === 1) {
        // Single file case
        if (errors.length > 0) {
            return next(new AppError(500, `Failed to upload file: ${errors[0].error}`));
        }
        
        res.status(200).json({
            message: "File uploaded successfully",
            file: uploadedFiles[0]
        });
    } else {
        // Multiple files case
        res.status(200).json({
            message: `${uploadedFiles.length} of ${files.length} files uploaded successfully`,
            files: uploadedFiles,
            errors: errors.length > 0 ? errors : undefined
        });
    }
});

// List files with visibility handling
export const listClubFiles = catchAsync(async (req, res, next) => {
    const { clubId, viewerEmail } = req.query;
    if (!clubId || !viewerEmail) return next(new AppError(400, "Club ID and viewerEmail are required"));

    const club = await Club.findById(clubId)
        .populate("secretary")
        .populate("members.userId")
        .populate({
            path: "files",
            options: { sort: { uploadedAt: -1 } }, // Sort files by upload time
        });

    if (!club) return next(new AppError(404, "Club not found"));

    const isSecretary = club.secretary?.email === viewerEmail;
    const isMember = club.members.some(member => member.userId?.email === viewerEmail);

    let files = club.files; // First try retrieving files from the Club model

    if (!files || files.length === 0) {
        // If Club model has no files, fetch from File collection
        files = await File.find({
            category: "club",
            referenceId: clubId,
            ...(isSecretary || isMember ? {} : { visibility: "public" }) // Show only public files for non-members
        }).sort({ uploadedAt: -1 });
    }

    res.status(200).json({ files });
});




// Download file with permission check
// can't dowload through public link , only for view , change this later if found any solution
export const downloadClubFile = catchAsync(async (req, res, next) => {
    const { fileId } = req.params;
    const { viewerEmail, clubId } = req.query; // Changed referenceId to clubId
    
    if (!viewerEmail || !clubId) return next(new AppError(400, "Viewer email and club ID are required"));

    const fileDoc = await File.findById(fileId);
    if (!fileDoc) return next(new AppError(404, "File not found"));

    if (fileDoc.visibility === "public") {
        return res.status(200).json({ downloadLink: fileDoc.link });
    }

    const club = await Club.findById(clubId).populate("secretary").populate("members.userId");
    if (!club) return next(new AppError(404, "Associated club not found"));

    const isSecretary = club.secretary?.email === viewerEmail;
    const isMember = club.members?.some(member => member.userId?.email === viewerEmail);

    if (isSecretary || isMember) {
        return res.status(200).json({ downloadLink: fileDoc.link });
    }

    return next(new AppError(403, "You don't have permission to access this file"));
});


// Get OneDrive storage info
export const getOneDriveStorageInfo = catchAsync(async (req, res, next) => {
    const { clubId } = req.query; // Changed referenceId to clubId
    
    if (!clubId) {
        return next(new AppError(400, "Club ID is required"));
    }

    const club = await Club.findById(clubId).populate("secretary");
    if (!club || !club.secretary) return next(new AppError(404, "Club or Secretary not found"));

    const accessToken = await getAccessTokenByEmail(club.secretary.email);
    if (!accessToken) {
        return next(new AppError(403, "Access token not found for this user"));
    }

    try {
        const driveResponse = await axios.get('https://graph.microsoft.com/v1.0/me/drive', {
            headers: { Authorization: `Bearer ${accessToken}` }
        });

        const quota = driveResponse.data.quota;
        const total = quota.total;
        const used = quota.used;
        const available = total - used;
        const percentUsed = Math.round((used / total) * 100);

        res.status(200).json({
            storage: {
                total: total,
                used: used,
                available: available,
                totalFormatted: formatBytes(total),
                usedFormatted: formatBytes(used),
                availableFormatted: formatBytes(available),
                percentUsed: percentUsed
            }
        });
    } catch (error) {
        console.error('Error getting OneDrive storage info:', error);
        return next(new AppError(500, 'Failed to retrieve OneDrive storage information'));
    }
});


// Delete a file
export const deleteClubFile = catchAsync(async (req, res, next) => {
    const { fileId } = req.params;
      const { userEmail } = req.query;

    
    if (!userEmail) return next(new AppError(400, "User email is required"));
    
    const fileDoc = await File.findById(fileId);
    if (!fileDoc) return next(new AppError(404, "File not found"));
    
    const club = await Club.findById(fileDoc.referenceId).populate("secretary");
    if (!club) return next(new AppError(404, "Associated club not found"));
    // console.log("club", club);
    // console.log("fileDoc", fileDoc);
    // console.log("userEmail", userEmail);
    // console.log("club.secretary.email", club.secretary.email);    
    // Only secretary can delete files
    if (club.secretary?.email.trim().toLowerCase() !== userEmail.trim().toLowerCase()) {
        return next(new AppError(403, "Only the club secretary can delete files"));
    }
    
    try {
        const accessToken = await getAccessTokenByEmail(userEmail);
        if (!accessToken) return next(new AppError(403, "Access token not found"));
        
        // Delete from OneDrive using the same path format as in upload
        const deleteUrl = `https://graph.microsoft.com/v1.0/me/drive/root:/iitgsync/${fileDoc.name}`;
        
        try {
            // Delete the file from OneDrive
            await axios.delete(deleteUrl, { 
                headers: { Authorization: `Bearer ${accessToken}` } 
            });
            console.log(`Successfully deleted file ${fileDoc.name} from OneDrive`);
        } catch (oneDriveError) {
            console.error('Error deleting from OneDrive:', oneDriveError.message);
            // Continue with local deletion even if OneDrive deletion fails
        }
        
        // Remove from club's files array
        await Club.findByIdAndUpdate(fileDoc.referenceId, {
            $pull: { files: fileId }
        });
        
        // Delete from database
        await File.findByIdAndDelete(fileId);
        
        res.status(200).json({
            message: "File deleted successfully"
        });
    } catch (error) {
        console.error('Error deleting file:', error);
        return next(new AppError(500, `Failed to delete file: ${error.message}`));
    }
});
