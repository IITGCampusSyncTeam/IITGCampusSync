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

    // In a real-world scenario, you'd fetch these tokens from your database
    // based on the participants or other criteria
    const fcmTokens = [
       "cv_aFs3BRL-Ahxhf4IMMzK:APA91bGzPdIVd8qVeJp6YxZNZez4_8oaFj05qdD-WPZ8pqHIVeN3Ri4tPtdv_L-xzedUqyx3jsTFUvR_Bw9a9Ws8CeTXZUZG1OOD2Tsa0JQJ9wXG9NKlNQ4"
    ];

    // Split tokens into chunks of 500 (FCM limit for batch send)
    const tokenChunks = chunkArray(fcmTokens, 500);

    let successCount = 0;
    let failureCount = 0;

    // Send notifications to each chunk
    for (const chunk of tokenChunks) {
      const message = {
        notification: {
          title: title,
          body: description,
        },
        tokens: chunk,  // An array of valid FCM tokens
      };
      try {
        const response = await admin.messaging().sendMulticast(message);

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
