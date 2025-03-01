import Event from './eventModel.js'; // Adjust the path as necessary
// import admin from 'firebase-admin';  // ⬅️ Commented out Firebase import

// Function to create an event (without Firebase notifications)
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

    /*
    // Firebase Notification Logic (Commented Out)
    const fcmTokens = [
      "eRAUdMcgT6GZZLwcx6fQER:APA91bGrK18600fJQ5j_2CjBoCCI6wRF6N16CU23Vy5nYQnVdbpGWwon7id8-VwSFqUR_DDyEte4bePCeWrR6bAaOwXpidDpDJbW8Li41ZUxELxax5CPvrk"
    ];

    const tokenChunks = chunkArray(fcmTokens, 500);

    let successCount = 0;
    let failureCount = 0;

    for (const token of fcmTokens) {
      const message = {
        notification: {
          title: title,
          body: description,
        },
        token: token,  
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

          console.log('Failed tokens:', failedTokens);
        }
      } catch (error) {
        console.error('Error sending notifications to chunk:', error);
        failureCount += chunk.length;
      }
    }
    */

    res.status(201).json({
      message: 'Event created successfully',
      event
    });
  } catch (err) {
    console.error('Error creating event:', err);
    res.status(500).json({ error: 'Error creating event' });
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

// Helper function to split array into chunks
function chunkArray(array, chunkSize) {
  const chunks = [];
  for (let i = 0; i < array.length; i += chunkSize) {
    chunks.push(array.slice(i, i + chunkSize));
  }
  return chunks;
}

export default {
  createEvent,
  getEvents,
};
