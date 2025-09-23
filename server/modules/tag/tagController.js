import Tag from "./tagModel.js";
import User from "../user/user.model.js";

export const getAllTags = async (req, res) => {
  try {
    const tags = await Tag.find();
    res.status(200).json(tags);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const addTags = async (req, res) => {
  try {
    const { titles } = req.body;

    if (!titles || !Array.isArray(titles) || titles.length === 0) {
      return res.status(400).json({ error: "Please provide an array of titles." });
    }

    const tagsToCreate = titles.map(title => ({ title }));
    const newTags = await Tag.insertMany(tagsToCreate);

    res.status(201).json(newTags);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

export const deleteTags = async (req, res) => {
  try {
    const { tagIds } = req.body;

    if (!tagIds || !Array.isArray(tagIds) || tagIds.length === 0) {
      return res.status(400).json({ error: "Please provide an array of tag IDs." });
    }

    const deleteResult = await Tag.deleteMany({ _id: { $in: tagIds } });

    if (deleteResult.deletedCount === 0) {
      return res.status(404).json({ error: "No matching tags found to delete." });
    }

    await User.updateMany(
      {},
      { $pull: { tag: { $in: tagIds } } }
    );

    res.status(200).json({ message: `${deleteResult.deletedCount} tags deleted successfully from the system and all user profiles.` });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};