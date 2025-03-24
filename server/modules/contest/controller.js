import axios from 'axios';
import Club from '../club/clubModel.js';
import EventModel from '../event/eventModel.js';
import User from '../user/user.model.js';
import { sendNotification } from '../notif/notificationService.js';

//codeforces club id
const CODEFORCES_CLUB_ID = '67e1978a717c73c22ea1c19f';

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



export const fetchAndAddContests = async () => {
    try {
        const response = await axios.get('https://codeforces.com/api/contest.list');
        if (response.data.status !== 'OK') {
            console.error('Error fetching contests from Codeforces');
            return;
        }

        const contests = response.data.result.filter(
            (contest) => contest.phase === 'BEFORE'
        ); // Get only upcoming contests

        // Fetch Codeforces club
        const club = await Club.findById(CODEFORCES_CLUB_ID);
        if (!club) {
            console.error('Codeforces club not found');
            return;
        }

        for (const contest of contests) {
            const existingEvent = await EventModel.findOne({ title: contest.name, club: CODEFORCES_CLUB_ID });
            console.log('Checking for existing event:', contest.name, CODEFORCES_CLUB_ID);

            if (existingEvent==null) {
                // Create a new event for the contest
                const newEvent = new EventModel({
                    title: contest.name,
                    description: `Codeforces contest: ${contest.name}`,
                    dateTime: new Date(contest.startTimeSeconds * 1000),
                    club: CODEFORCES_CLUB_ID
                });


                await newEvent.save();
                club.events.push(newEvent._id);
                await club.save();

                // Send notifications to followers
                await sendNotificationsToFollowers(club, newEvent);
            }
        }

        console.log('Contest fetching and notification completed');
    } catch (error) {
        console.error('Error fetching contests:', error);
    }
};



export const sendNotificationsToFollowers = async (club, event) => {
    try {
        const followers = await User.find({ _id: { $in: club.followers } });
        console.log('followerss',followers);
        const notificationData = {
            title: `New Codeforces Contest: ${event.name}`,
            body: `The contest starts on ${new Date(event.date).toLocaleString()}. Join here: ${event.link}`,

        };

        for (const follower of followers) {
            if (follower.fcmToken) {
                await sendNotification(follower.fcmToken, notificationData);
            }
        }

        console.log(`Notifications sent to ${followers.length} followers.`);
    } catch (error) {
        console.error('Error sending notifications:', error);
    }
};
