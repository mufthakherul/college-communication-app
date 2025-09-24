"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.markMessageAsRead = exports.sendMessage = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Messaging functions
exports.sendMessage = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
        const { recipientId, content, type } = data;
        const message = {
            senderId: context.auth.uid,
            recipientId,
            content,
            type: type || "text",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false
        };
        const docRef = await admin.firestore()
            .collection("messages")
            .add(message);
        // Send push notification to recipient
        await sendPushNotification(recipientId, {
            title: "New Message",
            body: content.substring(0, 50) + "...",
            data: {
                type: "message",
                messageId: docRef.id,
                senderId: context.auth.uid
            }
        });
        return { success: true, messageId: docRef.id };
    }
    catch (error) {
        console.error("Error sending message:", error);
        throw new functions.https.HttpsError("internal", "Failed to send message");
    }
});
exports.markMessageAsRead = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
        const { messageId } = data;
        await admin.firestore()
            .collection("messages")
            .doc(messageId)
            .update({
            read: true,
            readAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return { success: true };
    }
    catch (error) {
        console.error("Error marking message as read:", error);
        throw new functions.https.HttpsError("internal", "Failed to mark message as read");
    }
});
// Helper function to send push notifications
async function sendPushNotification(userId, notification) {
    try {
        const userDoc = await admin.firestore()
            .collection("users")
            .doc(userId)
            .get();
        if (!userDoc.exists) {
            return;
        }
        const userData = userDoc.data();
        const fcmToken = userData?.fcmToken;
        if (!fcmToken) {
            return;
        }
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: notification.title,
                body: notification.body
            },
            data: notification.data || {}
        });
    }
    catch (error) {
        console.error("Error sending push notification:", error);
    }
}
