import axios from 'axios';

export const getContestList = async (req, res) => {
    try {
        const response = await axios.get('https://codeforces.com/api/contest.list');
        if (response.data.status === "OK") {
            const contestList = response.data.result;
            res.status(200).json({ success: true, contests: contestList });
        } else {
            res.status(500).json({ success: false, message: "Failed to fetch contests" });
        }
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
