import User from "../modules/user/user.model.js";
import AppError from "../utils/appError.js";

const isAuthenticated = async function (req, res, next) {
    let token = req.cookies?.token;
    if (!token) token = req.headers?.authorization?.split(" ")[1];
    //if (!token) return next(new AppError(403, "Invalid token"));
    const user = await User.findByJWT(token);
    //if (!user) return next(new AppError(403, "Not Authenticated"));
    req.user = user;
    return next();
};

export default isAuthenticated;



// ffds