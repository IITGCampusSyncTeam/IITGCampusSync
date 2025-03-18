import jwt from "jsonwebtoken";
import User from "../modules/user/user.model.js";
import AppError from "../utils/appError.js";

const isAuthenticated = async (req, res, next) => {
    try {
        let token = req.cookies?.token;
        if (!token && req.headers?.authorization?.startsWith("Bearer ")) {
            token = req.headers.authorization.split(" ")[1];
        }

        if (!token) {
            return next(new AppError(403, "Unauthorized: No token provided"));
        }

        // Verify and decode token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const user = await User.findById(decoded.id); // Assuming JWT contains user ID

        if (!user) {
            return next(new AppError(403, "Unauthorized: User not found"));
        }

        req.user = user; // Attach user to request
        next();
    } catch (error) {
        return next(new AppError(403, "Unauthorized: Invalid or expired token"));
    }
};

export default isAuthenticated;
