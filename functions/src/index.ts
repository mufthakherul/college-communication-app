import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Import all cloud functions
export * from "./adminApproval";
export * from "./notices";
export * from "./messaging";
export * from "./userManagement";
export * from "./analytics";

// Health check endpoint
export const healthCheck = functions.https.onRequest((request, response) => {
  response.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    service: "college-communication-app-functions"
  });
});