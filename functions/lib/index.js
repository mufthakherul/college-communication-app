"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthCheck = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// Import all cloud functions
__exportStar(require("./adminApproval"), exports);
__exportStar(require("./notices"), exports);
__exportStar(require("./messaging"), exports);
__exportStar(require("./userManagement"), exports);
__exportStar(require("./analytics"), exports);
// Health check endpoint
exports.healthCheck = functions.https.onRequest((request, response) => {
    response.json({
        status: "ok",
        timestamp: new Date().toISOString(),
        service: "campus-mesh-functions"
    });
});
