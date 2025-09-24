"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.processApprovalRequest = exports.requestAdminApproval = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
// Admin approval workflow functions
exports.requestAdminApproval = functions.https.onCall(async (data, context) => {
    // Verify user authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    try {
        const { type, data: requestData } = data;
        // Create approval request document
        const approvalRequest = {
            userId: context.auth.uid,
            type,
            data: requestData,
            status: "pending",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        };
        const docRef = await admin.firestore()
            .collection("approvalRequests")
            .add(approvalRequest);
        return { success: true, requestId: docRef.id };
    }
    catch (error) {
        console.error("Error creating approval request:", error);
        throw new functions.https.HttpsError("internal", "Failed to create approval request");
    }
});
exports.processApprovalRequest = functions.https.onCall(async (data, context) => {
    // Verify admin authentication
    if (!context.auth) {
        throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
    }
    // Check if user is admin (implement your admin check logic)
    const userDoc = await admin.firestore()
        .collection("users")
        .doc(context.auth.uid)
        .get();
    if (!userDoc.exists || userDoc.data()?.role !== "admin") {
        throw new functions.https.HttpsError("permission-denied", "Insufficient permissions");
    }
    try {
        const { requestId, action, reason } = data;
        await admin.firestore()
            .collection("approvalRequests")
            .doc(requestId)
            .update({
            status: action, // "approved" or "rejected"
            processedBy: context.auth.uid,
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
            reason: reason || null
        });
        return { success: true };
    }
    catch (error) {
        console.error("Error processing approval request:", error);
        throw new functions.https.HttpsError("internal", "Failed to process approval request");
    }
});
