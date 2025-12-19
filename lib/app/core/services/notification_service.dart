// import 'dart:developer' as Console;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
//
// class NotificationService extends GetxService {
//
//   static NotificationService get instance => Get.find<NotificationService>();
//
//   late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
//   int _notificationIdCounter = 0;
//
//   // Notification channels
//   static const String _defaultChannelId = 'default_channel';
//   static const String _highPriorityChannelId = 'high_priority_channel';
//   static const String _lowPriorityChannelId = 'low_priority_channel';
//
//   Future<NotificationService> init() async {
//     _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//     await _initializeNotifications();
//     await _requestPermissions();
//
//     return this;
//   }
//
//   Future<void> _initializeNotifications() async {
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//     );
//
//     await _flutterLocalNotificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );
//   }
//
//   Future<void> _requestPermissions() async {
//     // Android permissions only
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//     _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//
//     if (androidImplementation != null) {
//       final bool? granted = await androidImplementation.requestNotificationsPermission();
//       Console.log('Notification permission granted: $granted', name: 'NotificationService');
//     }
//   }
//
//   void _onNotificationTapped(NotificationResponse response) {
//     Console.log('Notification tapped: ${response.payload}', name: 'NotificationService');
//     // Handle notification tap here
//     // You can navigate to specific screens based on payload
//   }
//
//   // Simple notification
//   Future<int> showNotification({
//     required String title,
//     required String body,
//     String? payload,
//     NotificationPriority priority = NotificationPriority.normal,
//   }) async {
//     final id = _generateNotificationId();
//
//     final details = _getNotificationDetails(priority);
//
//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       details,
//       payload: payload,
//     );
//
//     Console.log('Notification shown with ID: $id', name: 'NotificationService');
//     return id;
//   }
//
//   // Big text notification (Android)
//   Future<int> showBigTextNotification({
//     required String title,
//     required String body,
//     required String bigText,
//     String? payload,
//     NotificationPriority priority = NotificationPriority.normal,
//   }) async {
//     final id = _generateNotificationId();
//
//     final androidDetails = AndroidNotificationDetails(
//       _getChannelId(priority),
//       _getChannelName(priority),
//       channelDescription: _getChannelDescription(priority),
//       importance: _getImportance(priority),
//       priority: _getPriority(priority),
//       styleInformation: BigTextStyleInformation(
//         bigText,
//         contentTitle: title,
//         summaryText: 'Tap to read more',
//       ),
//     );
//
//     final details = NotificationDetails(android: androidDetails);
//
//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       details,
//       payload: payload,
//     );
//
//     return id;
//   }
//
//   // Progress notification (Android)
//   Future<int> showProgressNotification({
//     required String title,
//     required int progress,
//     int maxProgress = 100,
//     bool indeterminate = false,
//     String? payload,
//   }) async {
//     final id = _generateNotificationId();
//
//     final androidDetails = AndroidNotificationDetails(
//       _defaultChannelId,
//       'Default Channel',
//       channelDescription: 'Default notification channel',
//       importance: Importance.low,
//       priority: Priority.low,
//       showProgress: true,
//       maxProgress: maxProgress,
//       progress: progress,
//       indeterminate: indeterminate,
//       ongoing: true,
//       autoCancel: false,
//     );
//
//     final details = NotificationDetails(android: androidDetails);
//
//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       indeterminate ? 'Loading...' : '$progress/$maxProgress',
//       details,
//       payload: payload,
//     );
//
//     return id;
//   }
//
//   // Cancel specific notification
//   Future<void> cancelNotification(int id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//     Console.log('Notification with ID $id cancelled', name: 'NotificationService');
//   }
//
//   // Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//     Console.log('All notifications cancelled', name: 'NotificationService');
//   }
//
//   // Get pending notifications
//   Future<List<PendingNotificationRequest>> getPendingNotifications() async {
//     return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
//   }
//
//   // Utility methods
//   int _generateNotificationId() {
//     return ++_notificationIdCounter;
//   }
//
//   NotificationDetails _getNotificationDetails(NotificationPriority priority) {
//     final androidDetails = AndroidNotificationDetails(
//       _getChannelId(priority),
//       _getChannelName(priority),
//       channelDescription: _getChannelDescription(priority),
//       importance: _getImportance(priority),
//       priority: _getPriority(priority),
//       icon: '@mipmap/ic_launcher',
//     );
//
//     return NotificationDetails(android: androidDetails);
//   }
//
//   String _getChannelId(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.high:
//         return _highPriorityChannelId;
//       case NotificationPriority.low:
//         return _lowPriorityChannelId;
//       default:
//         return _defaultChannelId;
//     }
//   }
//
//   String _getChannelName(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.high:
//         return 'High Priority';
//       case NotificationPriority.low:
//         return 'Low Priority';
//       default:
//         return 'Default';
//     }
//   }
//
//   String _getChannelDescription(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.high:
//         return 'High priority notifications';
//       case NotificationPriority.low:
//         return 'Low priority notifications';
//       default:
//         return 'Default notifications';
//     }
//   }
//
//   Importance _getImportance(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.high:
//         return Importance.high;
//       case NotificationPriority.low:
//         return Importance.low;
//       default:
//         return Importance.defaultImportance;
//     }
//   }
//
//   Priority _getPriority(NotificationPriority priority) {
//     switch (priority) {
//       case NotificationPriority.high:
//         return Priority.high;
//       case NotificationPriority.low:
//         return Priority.low;
//       default:
//         return Priority.defaultPriority;
//     }
//   }
// }
//
// // Enums for better code organization
// enum NotificationPriority {
//   low,
//   normal,
//   high,
// }
//
//


import 'dart:developer' as Console;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import 'notification_storage_service.dart';

class NotificationService extends GetxService {

  static NotificationService get instance => Get.find<NotificationService>();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  int _notificationIdCounter = 0;

  // Notification channels
  static const String _defaultChannelId = 'default_channel';
  static const String _highPriorityChannelId = 'high_priority_channel';
  static const String _lowPriorityChannelId = 'low_priority_channel';

  Future<NotificationService> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await _initializeNotifications();
    await _requestPermissions();

    return this;
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      Console.log('Notification permission granted: $granted', name: 'NotificationService');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    Console.log('Notification tapped: ${response.payload}', name: 'NotificationService');

    // Mark as read in storage when tapped
    if (response.payload != null) {
      try {
        final storageController = Get.find<NotificationStorageController>();
        storageController.markAsRead(response.payload!);
      } catch (e) {
        Console.log('Storage controller not found', name: 'NotificationService');
      }
    }
  }

  // Simple notification with auto-storage
  Future<int> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
    bool saveToStorage = true, // Add option to save
    Map<String, dynamic>? additionalData,
  }) async {
    final id = _generateNotificationId();
    final notificationPayload = payload ?? id.toString();

    final details = _getNotificationDetails(priority);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: notificationPayload,
    );

    Console.log('Notification shown with ID: $id', name: 'NotificationService');

    // Auto-save to storage
    if (saveToStorage) {
      _saveNotificationToStorage(
        title: title,
        body: body,
        payload: notificationPayload,
        type: priority.name,
        additionalData: additionalData,
      );
    }

    return id;
  }

  // Big text notification with auto-storage
  Future<int> showBigTextNotification({
    required String title,
    required String body,
    required String bigText,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
    bool saveToStorage = true,
    Map<String, dynamic>? additionalData,
  }) async {
    final id = _generateNotificationId();
    final notificationPayload = payload ?? id.toString();

    final androidDetails = AndroidNotificationDetails(
      _getChannelId(priority),
      _getChannelName(priority),
      channelDescription: _getChannelDescription(priority),
      importance: _getImportance(priority),
      priority: _getPriority(priority),
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: 'Tap to read more',
      ),
    );

    final details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: notificationPayload,
    );

    // Auto-save to storage
    if (saveToStorage) {
      _saveNotificationToStorage(
        title: title,
        body: bigText, // Save full text
        payload: notificationPayload,
        type: 'big_text',
        additionalData: additionalData,
      );
    }

    return id;
  }

  // Progress notification (usually don't save these)
  Future<int> showProgressNotification({
    required String title,
    required int progress,
    int maxProgress = 100,
    bool indeterminate = false,
    String? payload,
    bool saveToStorage = false, // Progress notifications usually not saved
  }) async {
    final id = _generateNotificationId();

    final androidDetails = AndroidNotificationDetails(
      _defaultChannelId,
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: maxProgress,
      progress: progress,
      indeterminate: indeterminate,
      ongoing: true,
      autoCancel: false,
    );

    final details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      indeterminate ? 'Loading...' : '$progress/$maxProgress',
      details,
      payload: payload,
    );

    return id;
  }

  // Private method to save notification to storage
  void _saveNotificationToStorage({
    required String title,
    required String body,
    String? payload,
    String? type,
    Map<String, dynamic>? additionalData,
  }) {
    try {
      final storageController = Get.find<NotificationStorageController>();
      storageController.storeNotification(
        title: title,
        body: body,
        payload: payload,
        type: type,
        additionalData: additionalData,
      );
    } catch (e) {
      Console.log('Failed to save notification to storage: $e', name: 'NotificationService');
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    Console.log('Notification with ID $id cancelled', name: 'NotificationService');
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    Console.log('All notifications cancelled', name: 'NotificationService');
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Utility methods
  int _generateNotificationId() {
    return ++_notificationIdCounter;
  }

  NotificationDetails _getNotificationDetails(NotificationPriority priority) {
    final androidDetails = AndroidNotificationDetails(
      _getChannelId(priority),
      _getChannelName(priority),
      channelDescription: _getChannelDescription(priority),
      importance: _getImportance(priority),
      priority: _getPriority(priority),
      icon: '@mipmap/ic_launcher',
    );

    return NotificationDetails(android: androidDetails);
  }

  String _getChannelId(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return _highPriorityChannelId;
      case NotificationPriority.low:
        return _lowPriorityChannelId;
      default:
        return _defaultChannelId;
    }
  }

  String _getChannelName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'High Priority';
      case NotificationPriority.low:
        return 'Low Priority';
      default:
        return 'Default';
    }
  }

  String _getChannelDescription(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'High priority notifications';
      case NotificationPriority.low:
        return 'Low priority notifications';
      default:
        return 'Default notifications';
    }
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.low:
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.low:
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }
}

// Enums for better code organization
enum NotificationPriority {
  low,
  normal,
  high, medium,
}