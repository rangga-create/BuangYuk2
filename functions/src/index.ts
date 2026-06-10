import * as admin from 'firebase-admin';
admin.initializeApp();

export { registerUser, getUserRole, updateFcmToken, getAllUsers } from './auth';
export {
  createPickup, autoAssignNearestCollector, acceptPickup, rejectPickup,
  updatePickupStatus, getCitizenPickups, getCollectorPickups
} from './pickups';
export { updateCollectorLocation, syncLocationToRTDB, getCollectorLocation } from './tracking';
export {
  handleRewardOnPickupComplete, redeemReward, getWallet,
  getRewardTransactions, getLeaderboard
} from './rewards';
export { uploadWasteScan, getWasteScans } from './wasteScan';
export { onPickupStatusChange, onRewardTransaction } from './notifications';
export { getDashboardStats, dailyStatsJob } from './analytics';
export {
  createSchedule, updateSchedule, deleteSchedule, getSchedules,
  scheduleReminderH0, scheduleReminderH1
} from './schedules';
export { generateReport, getReports } from './reports';
