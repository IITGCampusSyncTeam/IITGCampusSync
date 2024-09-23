const express = require('express');
const admin = require('firebase-admin');
const path = require('path');

// Specify the path to your service account key file
const serviceAccountPath = path.join(__dirname, 'config', 'iitg-campus-sync.json');

// Initialize Firebase Admin SDK
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath)
  });
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error);
  process.exit(1);
}

const app = express();
app.use(express.json());


app.post('/send-notification', async (req, res) => {
  const { title, body, token } = req.body;

  if (!title || !body || !token) {
    return res.status(400).send('Missing required fields: title, body, or token');
  }

  const message = {
    notification: { title, body },
    token: token // use device token instead of topic
  };

   try {
      const response = await admin.messaging().send(message);
      console.log('Successfully sent message:', response);
      res.status(200).send('Notification sent successfully');
    } catch (error) {
      console.error('Error sending message:', error);
      res.status(500).send('Error sending notification');
    }
  });

  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

