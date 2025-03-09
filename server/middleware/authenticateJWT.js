const User = require("../modules/user/userModel.js");
/*C:\Users\sugan\Downloads\IITGCampusSync-main\server\modules\user\userModel.js */
const authenticateJWT = async function (req, res, next) {
    // const token = req.cookies.token;
    const token = req.headers?.authorization?.split(" ")[1]
    if (!token) return res.status(401).json({message: "Authentication required"});

    const user = User.findByJWT(token);

    if (!user) return res.status(403).json({message: "Invalid token"});
    req.user = user;
    return next();
}

module.exports = authenticateJWT;