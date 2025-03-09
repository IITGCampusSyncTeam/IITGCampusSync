import Club from './clubModel.js';
import Feedback from '../feedback/feedbackModel.js';

<<<<<<< HEAD
=======
// Create a new club
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
export const createClub = async (req, res) => {
    const { name, description, heads, members, images, websiteLink } = req.body;
    if (!req.user.isAdmin) return res.status(403).send('Unauthorized');
    try {
        const newClub = new Club({ name, description, heads, members, images, websiteLink });
        await newClub.save();
        res.status(201).json(newClub);
    } catch (err) {
        res.status(500).json({ message: 'Error creating club', error: err });
    }
};

<<<<<<< HEAD

=======
// Edit a club
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
export const editClub = async (req, res) => {
    const { id } = req.params;
    const updates = req.body;
    try {
        const club = await Club.findById(id);
        if (!club) return res.status(404).json({ message: 'Club not found' });
        if (!req.user.isAdmin || !club.heads.includes(req.user._id.toString())) return res.status(403).send('Unauthorized');
        Object.assign(club, updates);
        await club.save();
        res.status(200).json(club);
    } catch (err) {
        res.status(500).json({ message: 'Error updating club', error: err });
    }
};

<<<<<<< HEAD

=======
// Delete a club
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
export const deleteClub = async (req, res) => {
    const { id } = req.params;
    try {
        const club = await Club.findById(id);
        if (!club) return res.status(404).json({ message: 'Club not found' });
        if (!req.user.isAdmin || !club.heads.includes(req.user._id.toString())) return res.status(403).send('Unauthorized');
        await club.remove();
        res.status(200).json({ message: 'Club deleted' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting club', error: err });
    }
};

<<<<<<< HEAD

=======
// Add feedback to a club
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
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

<<<<<<< HEAD

=======
// Change authority of a club member
>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
export const changeAuthority = async (req, res) => {
    const { id } = req.params;
    const { userId, newRole } = req.body;
    try {
        const club = await Club.findById(id);
        if (!club) return res.status(404).json({ message: 'Club not found' });
        if (!req.user.isAdmin || !club.heads.includes(req.user._id.toString())) return res.status(403).send('Unauthorized');
        const member = club.members.find(member => member.userId === userId);
        if (!member) return res.status(404).json({ message: 'Member not found' });
        member.responsibility = newRole;
        await club.save();
        res.status(200).json(club);
    } catch (err) {
        res.status(500).json({ message: 'Error changing authority', error: err });
    }
<<<<<<< HEAD
};
=======
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


export const getClubDetail = async (req, res) => {
    const { id } = req.params;

    try {
        const club = await Club.findById(id)
            .populate('heads', 'name')  // Populate heads with names
            .populate('members.userId', 'name')  // Populate member user names
            .populate('events')  // Populate all event details
            .populate('merch');  // Populate all merch details

        if (!club) return res.status(404).json({ message: 'Club not found' });

        res.status(200).json(club);
    } catch (err) {
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

>>>>>>> 5f5db83884823f6e438f11fd55d1202d101d9050
