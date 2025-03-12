import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_usage/app_usage.dart';
import '../models/blocked_app.dart';
import 'database_service.dart';
import 'notification_service.dart';

class AppBlockerService {
  static final AppBlockerService _instance = AppBlockerService._internal();
  factory AppBlockerService() => _instance;
  AppBlockerService._internal();

  final DatabaseService _dbService = DatabaseService.instance;
  final NotificationService _notificationService = NotificationService();

  Future<bool> requestPermissions() async {
    final overlayStatus = await Permission.systemAlertWindow.request();
    // Note: Usage stats permission needs to be granted from system settings
    return overlayStatus.isGranted;
  }

  Future<List<Application>> getInstalledApps() async {
    return await DeviceApps.getInstalledApplications(
      includeAppIcons: true,
      includeSystemApps: false,
      onlyAppsWithLaunchIntent: true,
    );
  }

  Future<void> blockApp(String packageName, String appName) async {
    final blockedApp = BlockedApp(
      packageName: packageName,
      appName: appName,
      isBlocked: true,
    );
    await _dbService.insertBlockedApp(blockedApp);
  }

  Future<void> unblockApp(String packageName) async {
    await _dbService.deleteBlockedApp(packageName);
  }

  Future<void> setTimeLimit(String packageName, int minutes) async {
    final apps = await _dbService.getBlockedApps();
    final app = apps.firstWhere((app) => app.packageName == packageName);
    
    final updatedApp = BlockedApp(
      packageName: app.packageName,
      appName: app.appName,
      isBlocked: app.isBlocked,
      timeLimit: minutes,
      blockSchedules: app.blockSchedules,
    );
    
    await _dbService.updateBlockedApp(updatedApp);
  }

  Future<void> checkAppUsage() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(minutes: 1));
      
      final usage = AppUsage();
      final List<AppUsageInfo> usageStats = await usage.getAppUsage(startDate, endDate);
      final blockedApps = await _dbService.getBlockedApps();

      for (var appUsage in usageStats) {
        final blockedApp = blockedApps.firstWhere(
          (app) => app.packageName == appUsage.packageName,
          orElse: () => BlockedApp(
            packageName: appUsage.packageName,
            appName: appUsage.appName,
          ),
        );

        if (blockedApp.isBlocked) {
          await _notificationService.showBlockedAppNotification(blockedApp.appName);
          // Implement actual blocking mechanism here
        } else if (blockedApp.timeLimit > 0) {
          final usageTime = appUsage.usage.inMinutes;
          if (usageTime >= blockedApp.timeLimit) {
            await _notificationService.showTimeLimitNotification(blockedApp.appName);
            // Implement actual blocking mechanism here
          }
        }
      }
    } catch (e) {
      print('Error checking app usage: $e');
    }
  }

  Future<void> addBlockSchedule(String packageName, String schedule) async {
    final apps = await _dbService.getBlockedApps();
    final app = apps.firstWhere((app) => app.packageName == packageName);
    
    final updatedSchedules = List<String>.from(app.blockSchedules)..add(schedule);
    final updatedApp = BlockedApp(
      packageName: app.packageName,
      appName: app.appName,
      isBlocked: app.isBlocked,
      timeLimit: app.timeLimit,
      blockSchedules: updatedSchedules,
    );
    
    await _dbService.updateBlockedApp(updatedApp);
  }

  Future<void> removeBlockSchedule(String packageName, String schedule) async {
    final apps = await _dbService.getBlockedApps();
    final app = apps.firstWhere((app) => app.packageName == packageName);
    
    final updatedSchedules = List<String>.from(app.blockSchedules)
      ..removeWhere((s) => s == schedule);
    final updatedApp = BlockedApp(
      packageName: app.packageName,
      appName: app.appName,
      isBlocked: app.isBlocked,
      timeLimit: app.timeLimit,
      blockSchedules: updatedSchedules,
    );
    
    await _dbService.updateBlockedApp(updatedApp);
  }
} 