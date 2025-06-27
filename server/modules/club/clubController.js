import Club from './clubModel.js';
import Feedback from '../feedback/feedbackModel.js';
import Tag from '../tag/tagModel.js';
import User from '../user/user.model.js';
// Create a new club
export const createClub = async (req, res) => {
    const { name, description, email, members, images, websiteLink } = req.body;
    if (!req.user.isAdmin) return res.status(403).send('Unauthorized');
    try {
        const newClub = new Club({ name, description, email, members, images, websiteLink });
        await newClub.save();
        res.status(201).json(newClub);
    } catch (err) {
        res.status(500).json({ message: 'Error creating club', error: err });
    }
};

// Edit a club
export const editClub = async (req, res) => {
    const { id } = req.params;
    const updates = req.body;
    try {
        const club = await Club.findById(id);
        if (!club) return res.status(404).json({ message: 'Club not found' });
        if (!req.user.isAdmin) return res.status(403).send('Unauthorized');
        Object.assign(club, updates);
        await club.save();
        res.status(200).json(club);
    } catch (err) {
        res.status(500).json({ message: 'Error updating club', error: err });
    }
};

// Delete a club
export const deleteClub = async (req, res) => {
    const { id } = req.params;
    try {
        const club = await Club.findById(id);
        if (!club) return res.status(404).json({ message: 'Club not found' });
        if (!req.user.isAdmin) return res.status(403).send('Unauthorized');
        await club.remove();
        res.status(200).json({ message: 'Club deleted' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting club', error: err });
    }
};

// Add feedback to a club
export const addFeedback = async (req, res) => {
    const { id } = req.params;
    const { feedback } = req.body;
    try {
        const club = await Club.findById(id);
        if (!club) return res.status(404).json({ message: 'Club not found' });
        const newFeedback = new Feedback({ clubId: id, userId: req.user._id.toString(), feedback });
        await newFeedback.save();
        res.status(201).json(newFeedback);
    } catch (err) {
        res.status(500).json({ message: 'Error adding feedback', error: err });
    }
};

// Change authority of a club member
export const changeAuthority = async (req, res) => {
    const { id } = req.params;
    const { userId, newRole } = req.body;
    try {
        const club = await Club.findById(id);
        if (!club) return res.status(404).json({ message: 'Club not found' });
        if (!req.user.isAdmin) return res.status(403).send('Unauthorized');
        const member = club.members.find(member => member.userId === userId);
        if (!member) return res.status(404).json({ message: 'Member not found' });
        member.responsibility = newRole;
        await club.save();
        res.status(200).json(club);
    } catch (err) {
        res.status(500).json({ message: 'Error changing authority', error: err });
    }
};

export const getClubs = async (req, res) => {
    try {
        // Fetch only the fields needed for the frontend club list
        const clubs = await Club.find({}, 'id name description images websiteLink');

        res.status(200).json(clubs);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching clubs', error: err });
    }
};

// fetching all club info
export const getClubDetail = async (req, res) => {
    const { id } = req.params;

    try {
        console.log("Fetching club from database...");
        const clubDoc = await Club.findById(id)
            .populate('events')               // Populate all event details
            .populate('merch');               // Populate all merch details

        if (!clubDoc) {
            console.log("Club not found.");
            return res.status(404).json({ message: 'Club not found' });
        }

        const club = clubDoc.toObject(); // Convert Mongoose doc to plain object
        console.log("Club fetched:", club);

        // Handle tags
        if (!club.tag || club.tag.length === 0) {
            console.log("Club has no associated tags.");
            club.tag = [];
        } else {
            console.log("Fetching tag names for club...");
            const tagDocs = await Tag.find({ _id: { $in: club.tag } })
                .select("_id title")
                .lean();
            console.log("Tags retrieved:", tagDocs);

            club.tag = tagDocs.map(tag => ({
                id: tag._id.toString(),
                name: tag.title,
            }));
        }

        console.log("Final club data before sending:", JSON.stringify(club, null, 2));
        res.status(200).json(club);
    } catch (err) {
        console.error("Error fetching club details:", err);
        res.status(500).json({ message: 'Error fetching club details', error: err });
    }
};


export const addMerch = async (req, res) => {
    try {
        const { clubId } = req.params;
        const { name, description, price, image, sizes, type } = req.body;
        const userId = req.user.id; // Extracted from authentication middleware

        // Validate required fields
        if (!name || !description || !price || !image || !sizes || !type) {
            return res.status(400).json({ message: "All fields are required" });
        }

        // Validate price as a number
        const parsedPrice = parseFloat(price);
        if (isNaN(parsedPrice)) {
            return res.status(400).json({ message: "Invalid price format" });
        }

        // Find the club
        const club = await Club.findById(clubId);
        if (!club) return res.status(404).json({ message: "Club not found" });

        // Only the secretary can add merch
        if (club.secretary.toString() !== userId) {
            return res.status(403).json({ message: "Unauthorized: Only the secretary can add merch" });
        }

        // Create new merch item
        const newMerch = {
            name,
            description,
            price: parsedPrice, // Ensure price is stored as a number
            image,
            sizes,
            type
        };

        // Push new merch item and save
        club.merch.push(newMerch);
        await club.save();

        res.status(201).json({ message: "Merch added successfully", merch: newMerch });
    } catch (error) {
        console.error("Error adding merch:", error);
        res.status(500).json({ message: "Internal Server Error" });
    }
};

//  Delete Merch from a Club (Only Secretary)
export const deleteMerch = async (req, res) => {
    try {
        const { clubId, merchId } = req.params;
        const userId = req.user.id;

        const club = await Club.findById(clubId);
        if (!club) return res.status(404).json({ message: "Club not found" });

        // ✅ Check if the logged-in user is the club's secretary
        if (club.secretary.toString() !== userId) {
            return res.status(403).json({ message: "Unauthorized: Only the secretary can delete merch" });
        }

        // ✅ Remove the merch item
        const merchIndex = club.merch.findIndex((item) => item._id.toString() === merchId);
        if (merchIndex === -1) return res.status(404).json({ message: "Merch item not found" });

        club.merch.splice(merchIndex, 1);
        await club.save();

        res.status(200).json({ message: "Merch deleted successfully" });
    } catch (error) {
        console.error("Error deleting merch:", error);
        res.status(500).json({ message: "Internal Server Error" });
    }
};

// ✅ Add a Tag to a Club
export const addTagToClub = async (req, res) => {
    try {
        const { clubId, tagId } = req.params;

        const club = await Club.findById(clubId);
        if (!club) return res.status(404).json({ message: "Club not found" });

        const tag = await Tag.findById(tagId);
        if (!tag) return res.status(404).json({ message: "Tag not found" });

        // ✅ Add tag to club if not already present
        if (!club.tag.includes(tagId)) {
            club.tag.push(tagId);
            await club.save();
        }

        // ✅ Add club to tag's `clubs` array
        if (!tag.clubs.includes(clubId)) {
            tag.clubs.push(clubId);
            await tag.save();
        }

        res.status(200).json({ message: "Tag added to club", club });
    } catch (err) {
        console.error("Error adding tag to club:", err);
        res.status(500).json({ message: "Internal Server Error" });
    }
};


// ✅ Remove a Tag from a Club
export const removeTagFromClub = async (req, res) => {
    try {
        const { clubId, tagId } = req.params;

        const club = await Club.findById(clubId);
        if (!club) return res.status(404).json({ message: "Club not found" });

        const tag = await Tag.findById(tagId);
        if (!tag) return res.status(404).json({ message: "Tag not found" });

        // ✅ Remove tag from club's `tag` array
        club.tag = club.tag.filter((id) => id.toString() !== tagId);
        await club.save();

        // ✅ Remove club from tag's `clubs` array
        tag.clubs = tag.clubs.filter((id) => id.toString() !== clubId);
        await tag.save();

        res.status(200).json({ message: "Tag removed from club", club });
    } catch (err) {
        console.error("Error removing tag from club:", err);
        res.status(500).json({ message: "Internal Server Error" });
    }
};
export const addOrEditMember = async (req, res) => {
    const { clubId, email } = req.params;
    const { responsibility } = req.body;

    try {
        const club = await Club.findById(clubId);
        if (!club) return res.status(404).json({ message: 'Club not found' });

        const user = await User.findOne({ email });
        if (!user) return res.status(404).json({ message: 'User not found' });

        const existingMember = club.members.find(
            (member) => member.userId.toString() === user._id.toString()
        );

        if (existingMember) {
            // Edit responsibility
            existingMember.responsibility = responsibility;
        } else {
            // Add member
            club.members.push({ userId: user._id, responsibility });
        }

        await club.save();
        res.status(200).json({ message: 'Member added/updated', club });
    } catch (err) {
        console.error('Error adding/editing member:', err);
        res.status(500).json({ message: 'Internal server error' });
    }
};

// Remove member from club (authorization check removed)
export const removeMember = async (req, res) => {
    const { clubId, email } = req.params;

    try {
        const club = await Club.findById(clubId);
        if (!club) return res.status(404).json({ message: 'Club not found' });

        const user = await User.findOne({ email });
        if (!user) return res.status(404).json({ message: 'User not found' });

        const initialCount = club.members.length;
        club.members = club.members.filter(
            (member) => member.userId.toString() !== user._id.toString()
        );

        if (club.members.length === initialCount) {
            return res.status(404).json({ message: 'Member not found in club' });
        }

        await club.save();
        res.status(200).json({ message: 'Member removed', club });
    } catch (err) {
        console.error('Error removing member:', err);
        res.status(500).json({ message: 'Internal server error' });
    }
};








//func for following a club
export const followClub = async (req, res) => {
  try {
    const { clubId } = req.params;
    const { userId } = req.body;

    if (!clubId || !userId) {
      return res.status(400).json({ error: 'Missing clubId or userId' });
    }

    const club = await Club.findById(clubId);

    if (!club) {
      return res.status(404).json({ error: 'Club not found' });
    }

    // Check if user already follows the club
    const alreadyFollowing = club.followers.includes(userId);

    if (alreadyFollowing) {
      return res.status(400).json({ error: 'User already follows this club' });
    }

    // Add user to followers
    club.followers.push(userId);
    await club.save();

    res.status(200).json({ message: 'User successfully followed the club' });
  } catch (error) {
    console.error('Error following club:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Function to edit event info
export const editEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    const updates = req.body;

    const updatedEvent = await EventModel.findByIdAndUpdate(
      eventId,
      updates,
      { new: true }
    );

    if (!updatedEvent) {
      return res.status(404).json({ error: 'Event not found' });
    }

    res.status(200).json({ message: 'Event updated successfully', updatedEvent });
  } catch (error) {
    console.error('Error updating event info:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
};

