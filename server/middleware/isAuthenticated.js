import jwt from 'jsonwebtoken';

const isAuthenticated = (req, res, next) => {
  // --- DEVELOPMENT BYPASS ---
//  // This block will run ONLY if your server is in 'development' mode.
//  if (process.env.NODE_ENV === 'development') {
//
//    // 1. Paste the User ID you copied from MongoDB here.
//    const TEST_USER_ID = '67cdd269256701c667eb3c00';
//
//    console.log(`⚠️ AUTH MIDDLEWARE BYPASSED | Logged in as user: ${TEST_USER_ID} ⚠️`);
//
//    // 2. Create a fake user object and attach it to the request.
//    req.user = { id: TEST_USER_ID };
//
//    // 3. Skip the token check and proceed directly to the controller.
//    return next();
//  }
  // --- END OF BYPASS ---


  // --- PRODUCTION LOGIC ---
  // This is your original, secure code that will run on a live server.
  try {
    const token = req.headers.authorization.split(' ')[1];
    if (!token) {
      return res.status(403).json({ status: 'error', message: 'Not Authenticated' });
    }
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ status: 'error', message: 'Not Authenticated' });
  }
};

export default isAuthenticated;
