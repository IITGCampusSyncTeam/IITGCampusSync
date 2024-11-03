import Club from './clubModel.js';

export const createClub = async (req, res) => {
    const { name, description } = req.body;
    try {
        const newClub = new Club({ name, description });
        await newClub.save();
        res.status(201).json(newClub);
    } catch (err) {
        res.status(500).json({ message: 'Error creating club', error: err });
    }
};
