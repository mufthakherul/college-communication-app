import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Admin approval workflow functions
export const requestAdminApproval = functions.https.onCall(async (data, context) => {
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
  } catch (error) {
    console.error("Error creating approval request:", error);
    throw new functions.https.HttpsError("internal", "Failed to create approval request");
  }
});

export const processApprovalRequest = functions.https.onCall(async (data, context) => {
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
  } catch (error) {
    console.error("Error processing approval request:", error);
    throw new functions.https.HttpsError("internal", "Failed to process approval request");
  }
});