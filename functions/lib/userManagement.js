"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.updateUserRole = exports.deleteUserData = exports.updateUserProfile = exports.createUserProfile = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// User management functions
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
    try {
        const userProfile = {
            uid: user.uid,
            email: user.email,
            displayName: user.displayName || "",
            photoURL: user.photoURL || "",
            role: "student", // default role
            department: "",
            year: "",
            isActive: true,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };
        await admin.firestore()
            .collection("users")
            .doc(user.uid)
            .set(userProfile);
        console.log("User profile created for:", user.uid);
    }
    catch (error) {
        console.error("Error creating user profile:", error);
    }
});
exports.updateUserProfile = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
        const { updates } = data;
        // Remove sensitive fields that shouldn't be updated directly
        const allowedUpdates = { ...updates };
        delete allowedUpdates.uid;
        delete allowedUpdates.role; // Role updates should go through admin approval
        delete allowedUpdates.createdAt;
        await admin.firestore()
            .collection("users")
            .doc(context.auth.uid)
            .update({
            ...allowedUpdates,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return { success: true };
    }
    catch (error) {
        console.error("Error updating user profile:", error);
        throw new functions.https.HttpsError("internal", "Failed to update user profile");
    }
});
exports.deleteUserData = functions.auth.user().onDelete(async (user) => {
    try {
        // Delete user profile
        await admin.firestore()
            .collection("users")
            .doc(user.uid)
            .delete();
        // Delete user messages
        const messagesQuery = admin.firestore()
            .collection("messages")
            .where("senderId", "==", user.uid);
        const messagesSnapshot = await messagesQuery.get();
        const batch = admin.firestore().batch();
        messagesSnapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
        });
        await batch.commit();
        console.log("User data deleted for:", user.uid);
    }
    catch (error) {
        console.error("Error deleting user data:", error);
    }
});
exports.updateUserRole = functions.https.onCall(async (data, context) => {
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    // Check if user is admin
    const adminDoc = await admin.firestore()
        .collection("users")
        .doc(context.auth.uid)
        .get();
    if (!adminDoc.exists || adminDoc.data()?.role !== "admin") {
        throw new functions.https.HttpsError("permission-denied", "Insufficient permissions");
    }
    try {
        const { userId, newRole } = data;
        await admin.firestore()
            .collection("users")
            .doc(userId)
            .update({
            role: newRole,
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        return { success: true };
    }
    catch (error) {
        console.error("Error updating user role:", error);
        throw new functions.https.HttpsError("internal", "Failed to update user role");
    }
});
