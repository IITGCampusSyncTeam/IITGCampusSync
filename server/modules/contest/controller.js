import axios from 'axios';
import Club from '../club/clubModel.js';
import EventModel from '../event/eventModel.js';
import User from '../user/user.model.js';
import { sendNotification } from '../notif/notification_controller.js';

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
        );

        // Fetch Codeforces club by name
        const club = await Club.findOne({ name: 'codeforces' });
        if (!club) {
            console.error('Codeforces club not found');
            return;
        }

        for (const contest of contests) {
            const existingEvent = await EventModel.findOne({ title: contest.name, club: club._id });
            console.log('Checking for existing event:', contest.name, club._id);

            if (!existingEvent) {
                const newEvent = new EventModel({
                    title: contest.name,
                    description: `Codeforces contest: ${contest.name}`,
                    dateTime: new Date(contest.startTimeSeconds * 1000),
                    club: club._id
                });

                await newEvent.save();
                club.events.push(newEvent._id);
                await club.save();

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
            title: `New Codeforces Contest: ${event.title}`,
            body: `The contest starts on ${new Date(event.dateTime).toLocaleString()}. `,

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

export const removeFinishedContests = async () => {
  try {
    const response = await axios.get('https://codeforces.com/api/contest.list');
    if (response.data.status !== 'OK') {
      console.error('Error fetching contests from Codeforces');
      return;
    }

    const finishedContests = response.data.result.filter(
      (contest) => contest.phase === 'FINISHED'
    );

    // Find the club by name
    const codeforcesClub = await Club.findOne({ name:"codeforces" });

    if (!codeforcesClub) {
      console.error(`Club with name '${codeforces}' not found.`);
      return;
    }

    for (const contest of finishedContests) {
      const existingEvent = await EventModel.findOne({
        title: contest.name,
        club: codeforcesClub._id,
      });

      if (existingEvent) {
        await EventModel.findByIdAndDelete(existingEvent._id);
        await Club.updateOne(
          { _id: codeforcesClub._id },
          { $pull: { events: existingEvent._id } }
        );
        console.log(`Removed finished contest: ${contest.name}`);
      }
    }

    console.log('Finished contest removal completed');
  } catch (error) {
    console.error('Error removing finished contests:', error);
  }
};

//
//export const removeFinishedContests = async () => {
//    try {
//        const response = await axios.get('https://codeforces.com/api/contest.list');
//        if (response.data.status !== 'OK') {
//            console.error('Error fetching contests from Codeforces');
//            return;
//        }
//
//        const finishedContests = response.data.result.filter(
//            (contest) => contest.phase === 'FINISHED'
//        ); // Get only finished contests
//
//        for (const contest of finishedContests) {
//            const existingEvent = await EventModel.findOne({
//                title: contest.name,
//                club: CODEFORCES_CLUB_ID,
//            });
//
//            if (existingEvent) {
//                // Remove the finished event from the club's events list
//                await EventModel.findByIdAndDelete(existingEvent._id);
//                await Club.updateOne(
//                    { _id: CODEFORCES_CLUB_ID },
//                    { $pull: { events: existingEvent._id } }
//                );
//                console.log(`Removed finished contest: ${contest.name}`);
//            }
//        }
//
//        console.log('Finished contest removal completed');
//    } catch (error) {
//        console.error('Error removing finished contests:', error);
//    }
//};
