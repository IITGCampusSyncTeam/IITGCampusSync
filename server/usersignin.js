// makeToken.js
import jwt from "jsonwebtoken";

const userId = "689ae38dc2e68537ee47d823"; // user _id
const secret = "59dd99116b34145a36c10d2b59bffc0e8a5fe3bb5685f74c87321d414ada641a844931491d83cee3bec5be395cad655a16af17d40c748325ea09f9311e260485";      // same as process.env.JWT_SECRET
const token = jwt.sign({ id: userId }, secret, { expiresIn: "7d" });

console.log(token);
