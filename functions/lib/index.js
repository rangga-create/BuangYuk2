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
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getReports = exports.generateReport = exports.scheduleReminderH1 = exports.scheduleReminderH0 = exports.getSchedules = exports.deleteSchedule = exports.updateSchedule = exports.createSchedule = exports.dailyStatsJob = exports.getDashboardStats = exports.onRewardTransaction = exports.onPickupStatusChange = exports.getWasteScans = exports.uploadWasteScan = exports.getLeaderboard = exports.getRewardTransactions = exports.getWallet = exports.redeemReward = exports.handleRewardOnPickupComplete = exports.getCollectorLocation = exports.syncLocationToRTDB = exports.updateCollectorLocation = exports.getCollectorPickups = exports.getCitizenPickups = exports.updatePickupStatus = exports.rejectPickup = exports.acceptPickup = exports.autoAssignNearestCollector = exports.createPickup = exports.getAllUsers = exports.updateFcmToken = exports.getUserRole = exports.registerUser = void 0;
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
var auth_1 = require("./auth");
Object.defineProperty(exports, "registerUser", { enumerable: true, get: function () { return auth_1.registerUser; } });
Object.defineProperty(exports, "getUserRole", { enumerable: true, get: function () { return auth_1.getUserRole; } });
Object.defineProperty(exports, "updateFcmToken", { enumerable: true, get: function () { return auth_1.updateFcmToken; } });
Object.defineProperty(exports, "getAllUsers", { enumerable: true, get: function () { return auth_1.getAllUsers; } });
var pickups_1 = require("./pickups");
Object.defineProperty(exports, "createPickup", { enumerable: true, get: function () { return pickups_1.createPickup; } });
Object.defineProperty(exports, "autoAssignNearestCollector", { enumerable: true, get: function () { return pickups_1.autoAssignNearestCollector; } });
Object.defineProperty(exports, "acceptPickup", { enumerable: true, get: function () { return pickups_1.acceptPickup; } });
Object.defineProperty(exports, "rejectPickup", { enumerable: true, get: function () { return pickups_1.rejectPickup; } });
Object.defineProperty(exports, "updatePickupStatus", { enumerable: true, get: function () { return pickups_1.updatePickupStatus; } });
Object.defineProperty(exports, "getCitizenPickups", { enumerable: true, get: function () { return pickups_1.getCitizenPickups; } });
Object.defineProperty(exports, "getCollectorPickups", { enumerable: true, get: function () { return pickups_1.getCollectorPickups; } });
var tracking_1 = require("./tracking");
Object.defineProperty(exports, "updateCollectorLocation", { enumerable: true, get: function () { return tracking_1.updateCollectorLocation; } });
Object.defineProperty(exports, "syncLocationToRTDB", { enumerable: true, get: function () { return tracking_1.syncLocationToRTDB; } });
Object.defineProperty(exports, "getCollectorLocation", { enumerable: true, get: function () { return tracking_1.getCollectorLocation; } });
var rewards_1 = require("./rewards");
Object.defineProperty(exports, "handleRewardOnPickupComplete", { enumerable: true, get: function () { return rewards_1.handleRewardOnPickupComplete; } });
Object.defineProperty(exports, "redeemReward", { enumerable: true, get: function () { return rewards_1.redeemReward; } });
Object.defineProperty(exports, "getWallet", { enumerable: true, get: function () { return rewards_1.getWallet; } });
Object.defineProperty(exports, "getRewardTransactions", { enumerable: true, get: function () { return rewards_1.getRewardTransactions; } });
Object.defineProperty(exports, "getLeaderboard", { enumerable: true, get: function () { return rewards_1.getLeaderboard; } });
var wasteScan_1 = require("./wasteScan");
Object.defineProperty(exports, "uploadWasteScan", { enumerable: true, get: function () { return wasteScan_1.uploadWasteScan; } });
Object.defineProperty(exports, "getWasteScans", { enumerable: true, get: function () { return wasteScan_1.getWasteScans; } });
var notifications_1 = require("./notifications");
Object.defineProperty(exports, "onPickupStatusChange", { enumerable: true, get: function () { return notifications_1.onPickupStatusChange; } });
Object.defineProperty(exports, "onRewardTransaction", { enumerable: true, get: function () { return notifications_1.onRewardTransaction; } });
var analytics_1 = require("./analytics");
Object.defineProperty(exports, "getDashboardStats", { enumerable: true, get: function () { return analytics_1.getDashboardStats; } });
Object.defineProperty(exports, "dailyStatsJob", { enumerable: true, get: function () { return analytics_1.dailyStatsJob; } });
var schedules_1 = require("./schedules");
Object.defineProperty(exports, "createSchedule", { enumerable: true, get: function () { return schedules_1.createSchedule; } });
Object.defineProperty(exports, "updateSchedule", { enumerable: true, get: function () { return schedules_1.updateSchedule; } });
Object.defineProperty(exports, "deleteSchedule", { enumerable: true, get: function () { return schedules_1.deleteSchedule; } });
Object.defineProperty(exports, "getSchedules", { enumerable: true, get: function () { return schedules_1.getSchedules; } });
Object.defineProperty(exports, "scheduleReminderH0", { enumerable: true, get: function () { return schedules_1.scheduleReminderH0; } });
Object.defineProperty(exports, "scheduleReminderH1", { enumerable: true, get: function () { return schedules_1.scheduleReminderH1; } });
var reports_1 = require("./reports");
Object.defineProperty(exports, "generateReport", { enumerable: true, get: function () { return reports_1.generateReport; } });
Object.defineProperty(exports, "getReports", { enumerable: true, get: function () { return reports_1.getReports; } });
//# sourceMappingURL=index.js.map