import axios from "axios";
import fs from "fs";
import path from "path";
import catchAsync from "../../utils/catchAsync.js";
import AppError from "../../utils/appError.js";
import { getAccessTokenByEmail } from "../../utils/getAccessTokenByEmail.js";
import Club from "../club/club.model.js";

// 📤 Upload file to OneDrive and generate public shareable link
export const uploadToOneDrive = catchAsync(async (req, res, next) => {
    const { clubId } = req.body;
    const file = req.file;

    if (!file) return next(new AppError(400, "No file uploaded"));
    if (!clubId) return next(new AppError(400, "Club ID is required"));

    const club = await Club.findById(clubId).populate("secretary");
    if (!club || !club.clubSecretary) return next(new AppError(404, "Club or Club Secretary not found"));

    const email = club.clubSecretary.email;
    const accessToken = await getAccessTokenByEmail(email);
    if (!accessToken) return next(new AppError(403, "Access token not found"));

    const fileName = file.originalname;
    const uploadUrl = `https://graph.microsoft.com/v1.0/me/drive/root:/iitgsync/${fileName}:/content`;

    const fileStream = fs.createReadStream(file.path);

    // Upload file
    await axios.put(uploadUrl, fileStream, {
        headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": file.mimetype,
        },
    });

    // Make file publicly shareable
    const sharingUrl = `https://graph.microsoft.com/v1.0/me/drive/root:/iitgsync/${fileName}:/createLink`;
    const sharingResponse = await axios.post(
        sharingUrl,
        { type: "view", scope: "anonymous" },
        { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    const downloadLink = sharingResponse.data?.link?.webUrl;
    if (!downloadLink) return next(new AppError(500, "Failed to get shareable link"));

    fs.unlinkSync(file.path); // cleanup

    res.status(200).json({
        message: "File uploaded and shared successfully",
        downloadLink,
    });
});

// 📄 List all files under /iitgsync folder
export const listOneDriveFiles = catchAsync(async (req, res, next) => {
    const { clubId } = req.query;

    if (!clubId) return next(new AppError(400, "Club ID is required"));

    const club = await Club.findById(clubId).populate("clubHead");
    if (!club || !club.clubHead) return next(new AppError(404, "Club or Club Head not found"));

    const email = club.clubHead.email;
    const accessToken = await getAccessTokenByEmail(email);
    if (!accessToken) return next(new AppError(403, "Access token not found"));

    const listUrl = `https://graph.microsoft.com/v1.0/me/drive/root:/iitgsync:/children`;

    const listResponse = await axios.get(listUrl, {
        headers: { Authorization: `Bearer ${accessToken}` },
    });

    const files = listResponse.data.value.map(file => ({
        name: file.name,
        id: file.id,
        webUrl: file.webUrl
    }));

    res.status(200).json({ files });
});

// 🔽 Download file by name (via public link)
export const downloadOneDriveFile = catchAsync(async (req, res, next) => {
    const { clubId, fileName } = req.params;

    if (!clubId || !fileName) return next(new AppError(400, "Club ID and file name required"));

    const club = await Club.findById(clubId).populate("clubHead");
    if (!club || !club.clubHead) return next(new AppError(404, "Club or Club Head not found"));

    const email = club.clubHead.email;
    const accessToken = await getAccessTokenByEmail(email);
    if (!accessToken) return next(new AppError(403, "Access token not found"));

    const linkUrl = `https://graph.microsoft.com/v1.0/me/drive/root:/iitgsync/${fileName}:/createLink`;

    const sharingResponse = await axios.post(
        linkUrl,
        { type: "view", scope: "anonymous" },
        { headers: { Authorization: `Bearer ${accessToken}` } }
    );

    const publicLink = sharingResponse.data?.link?.webUrl;
    if (!publicLink) return next(new AppError(500, "Failed to generate public download link"));

    res.status(200).json({ downloadLink: publicLink });
});
