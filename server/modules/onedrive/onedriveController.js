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
import File from "./onedriveModel.js"; // ⬅️ updated file model

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const uploadDir = path.join(__dirname, "../../../uploads");

if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        cb(null, uniqueSuffix + "-" + file.originalname);
    },
});
export const uploadMiddleware = multer({ storage }).single("file");

// 📤 Upload and store metadata
// 📤 Upload and store metadata
export const uploadToOneDrive = catchAsync(async (req, res, next) => {
    const { category, referenceId } = req.body;
    const file = req.file;

    if (!file) return next(new AppError(400, "No file uploaded"));
    if (!category || !referenceId) return next(new AppError(400, "Category and Reference ID are required"));

    // Only club supported for now
    if (category !== "club") {
        return next(new AppError(400, "Currently only 'club' category is supported"));
    }

    const club = await Club.findById(referenceId).populate("secretary");
    if (!club || !club.secretary) return next(new AppError(404, "Club or Secretary not found"));

    const accessToken = await getAccessTokenByEmail(club.secretary.email);
    if (!accessToken) return next(new AppError(403, "Access token not found"));

    const filePath = file.path;
    const uploadUrl = `https://graph.microsoft.com/v1.0/me/drive/root:/iitgsync/${file.originalname}:/content`;

    // Upload with progress tracking
    const fileStream = fs.createReadStream(filePath);
    const uploadRes = await axios.put(uploadUrl, fileStream, {
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": file.mimetype,
        },
        maxBodyLength: Infinity,
        maxContentLength: Infinity,
        onUploadProgress: progressEvent => {
            const percent = Math.round((progressEvent.loaded * 100) / file.size);
            console.log(`Upload progress: ${percent}%`);
        },
    });

    const fileId = uploadRes.data?.id;

    const shareUrl = `https://graph.microsoft.com/v1.0/me/drive/items/${fileId}/createLink`;
    const shareRes = await axios.post(
        shareUrl,
        { type: "view", scope: "anonymous" },
        { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    const downloadLink = shareRes.data?.link?.webUrl;
    fs.unlinkSync(filePath); // Cleanup

    // Store in DB
    const savedFile = await File.create({
        category,
        referenceId,
        name: file.originalname,
        mimeType: file.mimetype,
        size: file.size,
        link: downloadLink,
        uploadedBy: club.secretary._id,
    });

    // ✅ Add the file reference to the club's files array
    await Club.findByIdAndUpdate(referenceId, {
        $push: { files: savedFile._id },
    });

    res.status(200).json({
        message: "Uploaded and stored successfully",
        file: savedFile,
    });
});


// 📄 List files (only public for normal users)
export const listClubFiles = catchAsync(async (req, res, next) => {
    const { referenceId, viewerEmail } = req.query;
    if (!referenceId || !viewerEmail) return next(new AppError(400, "Reference ID and viewerEmail required"));

    const club = await Club.findById(referenceId).populate("secretary");
    if (!club) return next(new AppError(404, "Club not found"));

    let files;
    const isSecretary = club.secretary?.email === viewerEmail;

    if (isSecretary) {
        files = await File.find({ category: "club", referenceId }).sort({ uploadedAt: -1 });
    } else {
        files = await File.find({ category: "club", referenceId }).sort({ uploadedAt: -1 });
    }

    res.status(200).json({ files });
});

// 🔽 Download via stored link
export const downloadClubFile = catchAsync(async (req, res, next) => {
    const { fileId } = req.params;
    const fileDoc = await File.findById(fileId);
    if (!fileDoc) return next(new AppError(404, "File not found"));

    res.status(200).json({ downloadLink: fileDoc.link });
});
