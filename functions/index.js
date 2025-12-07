const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Cloud Function to send push notifications when new classwork is created
 * Triggered when a notification is written to /Notifications/{studentId}/{notificationId}
 */
exports.sendClassworkNotification = functions.database
    .ref('/Notifications/{studentId}/{notificationId}')
    .onCreate(async (snapshot, context) => {
        try {
            const studentId = context.params.studentId;
            const notification = snapshot.val();

            // Get student's FCM token
            const tokenSnapshot = await admin.database()
                .ref(`fcmTokens/${studentId}/token`)
                .once('value');

            const token = tokenSnapshot.val();

            if (!token) {
                console.log(`No FCM token for student ${studentId}`);
                return null;
            }

            // Prepare notification payload
            const payload = {
                notification: {
                    title: notification.title || 'New Classwork',
                    body: notification.message || 'You have new classwork',
                    sound: 'default',
                },
                data: {
                    notificationId: context.params.notificationId,
                    classId: notification.classId || '',
                    classworkId: notification.classworkId || '',
                    type: notification.type || 'newClasswork',
                    click_action: 'FLUTTER_NOTIFICATION_CLICK',
                },
            };

            // Send notification
            const response = await admin.messaging().sendToDevice(token, payload);

            console.log('Notification sent successfully:', response);
            return response;
        } catch (error) {
            console.error('Error sending notification:', error);
            return null;
        }
    });

/**
 * Clean up old read notifications (older than 30 days)
 * Runs daily at midnight
 */
exports.cleanupOldNotifications = functions.pubsub
    .schedule('0 0 * * *')
    .timeZone('UTC')
    .onRun(async (context) => {
        const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
        const notificationsRef = admin.database().ref('Notifications');

        try {
            const snapshot = await notificationsRef.once('value');
            const updates = {};

            snapshot.forEach((studentSnapshot) => {
                const studentId = studentSnapshot.key;
                studentSnapshot.forEach((notificationSnapshot) => {
                    const notification = notificationSnapshot.val();
                    if (notification.isRead && notification.createdAt < thirtyDaysAgo) {
                        updates[`Notifications/${studentId}/${notificationSnapshot.key}`] = null;
                    }
                });
            });

            await admin.database().ref().update(updates);
            console.log(`Cleaned up ${Object.keys(updates).length} old notifications`);
            return null;
        } catch (error) {
            console.error('Error cleaning up notifications:', error);
            return null;
        }
    });
