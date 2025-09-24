"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateNotice = exports.createNotice = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Notice management functions
exports.createNotice = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
        const { title, content, type, targetAudience, expiresAt } = data;
        const notice = {
            title,
            content,
            type,
            targetAudience,
            authorId: context.auth.uid,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: expiresAt ? new Date(expiresAt) : null,
            isActive: true
        };
        const docRef = await admin.firestore()
            .collection("notices")
            .add(notice);
        // Send notifications to target audience
        await sendNoticeNotifications(docRef.id, notice);
        return { success: true, noticeId: docRef.id };
    }
    catch (error) {
        console.error("Error creating notice:", error);
        throw new functions.https.HttpsError("internal", "Failed to create notice");
    }
});
exports.updateNotice = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
        const { noticeId, updates } = data;
        // Verify ownership or admin rights
        const noticeDoc = await admin.firestore()
            .collection("notices")
            .doc(noticeId)
            .get();
        if (!noticeDoc.exists) {
            throw new functions.https.HttpsError("not-found", "Notice not found");
        }
        const noticeData = noticeDoc.data();
        if (noticeData?.authorId !== context.auth.uid) {
            // Check if user is admin
            const userDoc = await admin.firestore()
                .collection("users")
                .doc(context.auth.uid)
                .get();
            if (!userDoc.exists || userDoc.data()?.role !== "admin") {
                throw new functions.https.HttpsError("permission-denied", "Insufficient permissions");
            }
        }
        await admin.firestore()
            .collection("notices")
            .doc(noticeId)
            .update({
            ...updates,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return { success: true };
    }
    catch (error) {
        console.error("Error updating notice:", error);
        throw new functions.https.HttpsError("internal", "Failed to update notice");
    }
});
// Helper function to send notifications
async function sendNoticeNotifications(noticeId, notice) {
    try {
        // Get users matching target audience
        let usersQuery = admin.firestore().collection("users").where("isActive", "==", true);
        if (notice.targetAudience && notice.targetAudience !== "all") {
            usersQuery = usersQuery.where("role", "==", notice.targetAudience);
        }
        const usersSnapshot = await usersQuery.get();
        const notifications = usersSnapshot.docs.map(userDoc => ({
            userId: userDoc.id,
            type: "notice",
            title: notice.title,
            body: notice.content.substring(0, 100) + "...",
            data: {
                noticeId,
                type: notice.type
            },
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            read: false
        }));
        // Batch write notifications
        const batch = admin.firestore().batch();
        notifications.forEach(notification => {
            const notificationRef = admin.firestore().collection("notifications").doc();
            batch.set(notificationRef, notification);
        });
        await batch.commit();
    }
    catch (error) {
        console.error("Error sending notice notifications:", error);
    }
}
