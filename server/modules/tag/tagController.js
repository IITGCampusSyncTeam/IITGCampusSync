import Tag from "./tagModel.js";

// Get all tags
export const getAllTags = async (req, res) => {
  try {
    const tags = await Tag.find();
    res.status(200).json(tags);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Add a new tag
export const addTag = async (req, res) => {
  try {
    const { title } = req.body;
    const tag = new Tag({ title });
    await tag.save();
    res.status(201).json(tag);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Delete a tag by ID
export const deleteTag = async (req, res) => {
  try {
    const tag = await Tag.findByIdAndDelete(req.params.id);
    if (!tag) {
      return res.status(404).json({ error: "Tag not found" });
    }
    res.status(200).json({ message: "Tag deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
