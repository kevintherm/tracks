import 'package:workmanager/workmanager.dart';
import 'dart:developer';

class RunnableTask {
  final String name;
  final Future<void> Function() run;

  const RunnableTask({required this.name, required this.run});
}

/// Service that handles periodic background syncing.
class SyncService {
  static const String taskName = "syncCloudData";
  static final List<RunnableTask> _tasks = [];

  static void registerTask(RunnableTask task) {
    _tasks.add(task);
  }

  static Future<void> initialize() async {
    await Workmanager().initialize(_callbackDispatcher);
  }

  static Future<void> registerSync() async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(minutes: 5),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    log("[SyncService] Registered hourly sync task");
  }

  /// Cancels the background sync (e.g., when user logs out)
  static Future<void> cancelSync() async {
    await Workmanager().cancelByUniqueName(taskName);
    log("[SyncService] Cancelled sync task");
  }

  /// The entry point for Workmanager — must be a top-level or static function
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      log("[SyncService] Running background sync...");

      try {
        await _performSync();
      } catch (e, st) {
        log("[SyncService] Sync failed: $e\n$st");
      }

      return Future.value(true);
    });
  }

  static Future<void> _performSync() async {
    log("[SyncService] Fetching updates from server...");
    await Future.delayed(const Duration(seconds: 2));

    for (final t in _tasks) {
      log("[SyncService] Running task: ${t.name}");
      await t.run();
    }

    log("[SyncService] ✅ All tasks complete");
  }
}
