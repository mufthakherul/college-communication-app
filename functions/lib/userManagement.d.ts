import * as functions from "firebase-functions";
export declare const createUserProfile: functions.CloudFunction<import("firebase-admin/auth").UserRecord>;
export declare const updateUserProfile: functions.HttpsFunction & functions.Runnable<any>;
export declare const deleteUserData: functions.CloudFunction<import("firebase-admin/auth").UserRecord>;
export declare const updateUserRole: functions.HttpsFunction & functions.Runnable<any>;
