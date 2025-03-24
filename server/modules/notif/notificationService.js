import admin from 'firebase-admin';

const sendNotification = async (token, data) => {
    const message = {
        token: token,
        notification: {
            title: data.title,
            body: data.body
        },

    };

    try {
        await admin.messaging().send(message);
        console.log('Notification sent successfully');
    } catch (error) {
        console.error('Error sending notification:', error);
    }
};

export { sendNotification };
