import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';

import '../ui/player/player_controller.dart';
import '../ui/screens/Settings/settings_screen_controller.dart';
import '../utils/helper.dart';

/// Service that shows a desktop notification whenever the current track
/// changes.  Only active when both background playback and the
/// "Show track change notification" setting are enabled.
class DesktopNotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(settings,
        onDidReceiveNotificationResponse: _onNotificationResponse);
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == 'skip' || response.actionId == 'NEXT') {
      try {
        Get.find<PlayerController>().next();
      } catch (_) {
        // controller not ready
      }
    }
  }

  Future<void> showTrackChange(MediaItem item) async {
    final settings = Get.find<SettingsScreenController>();

    if (!GetPlatform.isDesktop ||
        !settings.backgroundPlayEnabled.value ||
        !settings.desktopTrackNotificationsEnabled.value) {
      return;
    }

    final title = item.title;
    final body = item.artist ?? '';

    final linuxDetails = LinuxNotificationDetails(
      actions: [LinuxNotificationAction(key: 'skip', label: 'Skip')],
    );

    final macosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'playback',
    );

    final details = NotificationDetails(
      linux: linuxDetails,
      macOS: macosDetails,
      android: const AndroidNotificationDetails(
        'harmony_track_channel',
        'Track changes',
        channelDescription: 'Desktop track change notifications (unused)',
        importance: Importance.defaultImportance,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('skip', 'Skip'),
        ],
      ),
    );

    try {
      // Show notification with ID 0, reused for track changes
      final linuxPlugin = _plugin.resolvePlatformSpecificImplementation<
          LinuxFlutterLocalNotificationsPlugin>();
      if (linuxPlugin != null) {
        await linuxPlugin.show(0, title, body,
            notificationDetails: linuxDetails, payload: 'track');
      }

      final macosPlugin = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      if (macosPlugin != null) {
        await macosPlugin.show(0, title, body,
            notificationDetails: macosDetails, payload: 'track');
      }
    } catch (e) {
      printERROR('desktop notification error: $e');
    }
  }

  Future<void> cancel() async {
    await _plugin.cancelAll();
  }
}
