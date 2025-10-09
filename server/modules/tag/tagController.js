import Tag from "./tagModel.js";
import User from "../user/user.model.js";

// Get all tags
export const getAllTags = async (req, res) => {
  try {
    const tags = await Tag.find();
    res.status(200).json(tags);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Add multiple tags at once
export const addTags = async (req, res) => {
  try {
    const { titles } = req.body;
    if (!titles || !Array.isArray(titles) || titles.length === 0)
      return res.status(400).json({ error: "Please provide an array of titles." });

    const tagsToCreate = titles.map((title) => ({ title }));
    const newTags = await Tag.insertMany(tagsToCreate);
    res.status(201).json(newTags);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete multiple tags
export const deleteTags = async (req, res) => {
  try {
    const { tagIds } = req.body;
    if (!tagIds || !Array.isArray(tagIds) || tagIds.length === 0)
      return res.status(400).json({ error: "Please provide an array of tag IDs." });

    const deleteResult = await Tag.deleteMany({ _id: { $in: tagIds } });

    if (deleteResult.deletedCount === 0)
      return res.status(404).json({ error: "No matching tags found to delete." });

    await User.updateMany({}, { $pull: { tag: { $in: tagIds } } });

    res.status(200).json({
      message: `${deleteResult.deletedCount} tags deleted successfully from the system and all user profiles.`,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Replace user tags completely (Delete old and add new) (Continue button logic in interests_page)
export const updateUserTags = async (req, res) => {
  try {
    const { email, tagIds } = req.body;

    if (!email || !Array.isArray(tagIds)) {
      return res.status(400).json({ error: "Email and tagIds array are required" });
    }

    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ error: "User not found" });

    // Remove user from previous tags
    await Tag.updateMany({ _id: { $in: user.tag } }, { $pull: { users: user._id } });

    // Update user's tag list
    user.tag = tagIds;
    await user.save();

    // Add user to each new tag
    await Tag.updateMany({ _id: { $in: tagIds } }, { $addToSet: { users: user._id } });

    res.status(200).json({ message: "User tags updated successfully" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
