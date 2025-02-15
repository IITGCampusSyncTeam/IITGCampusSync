import Event from './eventModel.js'; // Adjust the path as necessary
import admin from 'firebase-admin';

// Function to create an event and send notifications
const createEvent = async (req, res) => {
  const { title, description, dateTime, club, createdBy, participants } = req.body;

  if (!title || !description) {
    return res.status(400).send('Missing required fields: title, description');
  }

  try {
    // Create event logic
    const event = new Event(req.body);
    await event.save();
    console.log('Event saved successfully:', event);

    // In a real-world scenario, you'd fetch these tokens from your database
    // based on the participants or other criteria
    const fcmTokens = [
      "eRAUdMcgT6GZZLwcx6fQER:APA91bGrK18600fJQ5j_2CjBoCCI6wRF6N16CU23Vy5nYQnVdbpGWwon7id8-VwSFqUR_DDyEte4bePCeWrR6bAaOwXpidDpDJbW8Li41ZUxELxax5CPvrk"
    ];




    // Split tokens into chunks of 500 (FCM limit for batch send)
    const tokenChunks = chunkArray(fcmTokens, 500);

    let successCount = 0;
    let failureCount = 0;

    // Send notifications to each chunk
    for (const token of fcmTokens) {
     const message = {
          notification: {
            title: title,
            body: description,
          },
          token: token,  // An array of valid FCM tokens
        };
      try {
        const response = await admin.messaging().send(message);

        console.log(`${response.successCount} messages were sent successfully`);

        successCount += response.successCount;
        failureCount += response.failureCount;

        if (response.failureCount > 0) {
          const failedTokens = [];
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              failedTokens.push(chunk[idx]);
              console.error('Notification failed to send to:', chunk[idx]);
              console.error('Error:', resp.error);
            }
          });

          // Here you might want to handle failed tokens, e.g., remove them from your database
          console.log('Failed tokens:', failedTokens);
        }
      } catch (error) {
        console.error('Error sending notifications to chunk:', error);
        failureCount += chunk.length;
      }
    }

    res.status(201).json({
      message: 'Event created and notifications sent',
      event,
      notificationStats: {
        successCount,
        failureCount,
      }
    });
  } catch (err) {
    console.error('Error creating event or sending notifications:', err);
    res.status(500).json({ error: 'Error creating event or sending notifications' });
  }
};

// Function to fetch events
const getEvents = async (req, res) => {
  try {
    const events = await Event.find();
    res.status(200).json(events);
  } catch (error) {
    console.error('Error fetching events:', error);
    res.status(500).json({ message: 'Failed to fetch events' });
  }
};

// Function to get FCM tokens of all users (used in createEvent)

//const getFcmTokensOfUsers = async (userIds) => {
//  try {
//    // Find users by their IDs and return their FCM tokens
//    const users = await User.find({ _id: { $in: userIds } });
//    const fcmTokens = users.map(user => user.fcmToken).filter(token => token !== undefined);
//
//    return fcmTokens;
//  } catch (err) {
//    console.error('Error retrieving FCM tokens:', err);
//    throw err;
//  }
//};


// Helper function to split array into chunks
function chunkArray(array, chunkSize) {
  const chunks = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    chunks.push(array.slice(i, i + chunkSize));
  }
  return chunks;
}

export default{
  createEvent,
  getEvents,
};
