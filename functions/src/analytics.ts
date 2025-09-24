import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Analytics functions
export const trackUserActivity = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  try {
    const { action, metadata } = data;
    
    const activity = {
      userId: context.auth.uid,
      action,
      metadata: metadata || {},
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userAgent: context.rawRequest.headers["user-agent"] || "",
      ipAddress: context.rawRequest.ip || ""
    };

    await admin.firestore()
      .collection("userActivity")
      .add(activity);

    return { success: true };
  } catch (error) {
    console.error("Error tracking user activity:", error);
    throw new functions.https.HttpsError("internal", "Failed to track user activity");
  }
});

export const generateAnalyticsReport = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  // Check if user is admin
  const userDoc = await admin.firestore()
    .collection("users")
    .doc(context.auth.uid)
    .get();
  
  if (!userDoc.exists || userDoc.data()?.role !== "admin") {
    throw new functions.https.HttpsError("permission-denied", "Insufficient permissions");
  }

  try {
    const { reportType, startDate, endDate } = data;
    
    const start = new Date(startDate);
    const end = new Date(endDate);
    
    let report = {};
    
    switch (reportType) {
      case "user_activity":
        report = await generateUserActivityReport(start, end);
        break;
      case "notices":
        report = await generateNoticesReport(start, end);
        break;
      case "messages":
        report = await generateMessagesReport(start, end);
        break;
      default:
        throw new functions.https.HttpsError("invalid-argument", "Invalid report type");
    }

    return { success: true, report };
  } catch (error) {
    console.error("Error generating analytics report:", error);
    throw new functions.https.HttpsError("internal", "Failed to generate analytics report");
  }
});

async function generateUserActivityReport(startDate: Date, endDate: Date) {
  const snapshot = await admin.firestore()
    .collection("userActivity")
    .where("timestamp", ">=", startDate)
    .where("timestamp", "<=", endDate)
    .get();

  const activities = snapshot.docs.map(doc => doc.data());
  
  return {
    totalActivities: activities.length,
    uniqueUsers: new Set(activities.map(a => a.userId)).size,
    topActions: getTopActions(activities),
    dailyBreakdown: getDailyBreakdown(activities)
  };
}

async function generateNoticesReport(startDate: Date, endDate: Date) {
  const snapshot = await admin.firestore()
    .collection("notices")
    .where("createdAt", ">=", startDate)
    .where("createdAt", "<=", endDate)
    .get();

  const notices = snapshot.docs.map(doc => doc.data());
  
  return {
    totalNotices: notices.length,
    activeNotices: notices.filter(n => n.isActive).length,
    byType: getNoticesByType(notices),
    byAuthor: getNoticesByAuthor(notices)
  };
}

async function generateMessagesReport(startDate: Date, endDate: Date) {
  const snapshot = await admin.firestore()
    .collection("messages")
    .where("createdAt", ">=", startDate)
    .where("createdAt", "<=", endDate)
    .get();

  const messages = snapshot.docs.map(doc => doc.data());
  
  return {
    totalMessages: messages.length,
    readMessages: messages.filter(m => m.read).length,
    byType: getMessagesByType(messages)
  };
}

function getTopActions(activities: any[]) {
  const actionCounts: { [key: string]: number } = {};
  activities.forEach(activity => {
    actionCounts[activity.action] = (actionCounts[activity.action] || 0) + 1;
  });
  
  return Object.entries(actionCounts)
    .sort(([, a], [, b]) => b - a)
    .slice(0, 10);
}

function getDailyBreakdown(activities: any[]) {
  const dailyCounts: { [key: string]: number } = {};
  activities.forEach(activity => {
    const date = activity.timestamp.toDate().toDateString();
    dailyCounts[date] = (dailyCounts[date] || 0) + 1;
  });
  
  return dailyCounts;
}

function getNoticesByType(notices: any[]) {
  const typeCounts: { [key: string]: number } = {};
  notices.forEach(notice => {
    typeCounts[notice.type] = (typeCounts[notice.type] || 0) + 1;
  });
  
  return typeCounts;
}

function getNoticesByAuthor(notices: any[]) {
  const authorCounts: { [key: string]: number } = {};
  notices.forEach(notice => {
    authorCounts[notice.authorId] = (authorCounts[notice.authorId] || 0) + 1;
  });
  
  return authorCounts;
}

function getMessagesByType(messages: any[]) {
  const typeCounts: { [key: string]: number } = {};
  messages.forEach(message => {
    typeCounts[message.type] = (typeCounts[message.type] || 0) + 1;
  });
  
  return typeCounts;
}