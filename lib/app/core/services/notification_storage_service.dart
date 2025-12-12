// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'dart:async';
//
// class NotificationStorageController extends GetxController {
//   final storage = GetStorage();
//   final notifications = <Map<String, dynamic>>[].obs;
//   Timer? cleanupTimer;
//
//
//   final isLoading = false.obs;
//   final errorMessage = ''.obs;
//
//   static const String NOTIFICATIONS_KEY = 'notifications';
//   static const String LAST_CLEANUP_KEY = 'last_cleanup_date';
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadNotifications();
//     checkAndCleanup();
//     scheduleNextCleanup();
//   }
//
//   @override
//   void onClose() {
//     cleanupTimer?.cancel();
//     super.onClose();
//   }
//
//   // Add new notification when received
//   void storeNotification({
//     required String title,
//     required String body,
//     String? payload,
//     String? type,
//     Map<String, dynamic>? additionalData,
//   }) {
//     final notification = {
//       'id': DateTime.now().millisecondsSinceEpoch.toString(),
//       'title': title,
//       'body': body,
//       'payload': payload,
//       'type': type ?? 'default',
//       'timestamp': DateTime.now().millisecondsSinceEpoch,
//       'isRead': false,
//       'additionalData': additionalData,
//     };
//
//     notifications.insert(0, notification); // Add at top
//     saveNotifications();
//     print('📥 Notification stored: $title');
//   }
//
//   // Save notifications to storage
//   void saveNotifications() {
//     storage.write(NOTIFICATIONS_KEY, notifications.toList());
//   }
//
//   // Load notifications from storage
//   void loadNotifications() {
//     final stored = storage.read(NOTIFICATIONS_KEY);
//     if (stored != null) {
//       notifications.value = List<Map<String, dynamic>>.from(stored);
//     }
//   }
//
//   // Check if cleanup is needed and perform it
//   void checkAndCleanup() {
//     final lastCleanup = storage.read(LAST_CLEANUP_KEY);
//     final now = DateTime.now();
//
//     // Convert to IST
//     final istNow = now.toUtc().add(Duration(hours: 5, minutes: 30));
//
//     if (lastCleanup == null) {
//       storage.write(LAST_CLEANUP_KEY, istNow.toIso8601String());
//       return;
//     }
//
//     final lastCleanupDate = DateTime.parse(lastCleanup);
//
//     // Check if it's a new day and past 6 AM IST
//     if (istNow.day != lastCleanupDate.day ||
//         istNow.month != lastCleanupDate.month ||
//         istNow.year != lastCleanupDate.year) {
//
//       if (istNow.hour >= 6) {
//         clearAllNotifications();
//         storage.write(LAST_CLEANUP_KEY, istNow.toIso8601String());
//         print('✅ Notifications cleared at 6 AM IST: ${istNow.toString()}');
//       }
//     }
//   }
//
//   // Schedule next cleanup at 6 AM IST
//   void scheduleNextCleanup() {
//     final now = DateTime.now();
//     final istNow = now.toUtc().add(Duration(hours: 5, minutes: 30));
//
//     DateTime nextCleanup;
//     if (istNow.hour < 6) {
//       nextCleanup = DateTime(istNow.year, istNow.month, istNow.day, 6, 0, 0);
//     } else {
//       final tomorrow = istNow.add(Duration(days: 1));
//       nextCleanup = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6, 0, 0);
//     }
//
//     final nextCleanupLocal = nextCleanup.subtract(Duration(hours: 5, minutes: 30));
//     final duration = nextCleanupLocal.difference(now);
//
//     print('⏰ Next cleanup at 6 AM IST in: ${duration.inHours}h ${duration.inMinutes % 60}m');
//
//     cleanupTimer?.cancel();
//
//     cleanupTimer = Timer(duration, () {
//       clearAllNotifications();
//       storage.write(LAST_CLEANUP_KEY, DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30)).toIso8601String());
//       print('✅ Scheduled cleanup executed at 6 AM IST');
//       scheduleNextCleanup();
//     });
//   }
//
//   // Clear all notifications
//   void clearAllNotifications() {
//     notifications.clear();
//     storage.remove(NOTIFICATIONS_KEY);
//     print('🗑️ All notifications cleared');
//   }
//
//   // Remove single notification
//   void removeNotification(String id) {
//     notifications.removeWhere((notif) => notif['id'] == id);
//     saveNotifications();
//   }
//
//   // Mark notification as read
//   void markAsRead(String id) {
//     final index = notifications.indexWhere((notif) => notif['id'] == id);
//     if (index != -1) {
//       notifications[index]['isRead'] = true;
//       saveNotifications();
//     }
//   }
//
//   // Get unread count
//   int get unreadCount => notifications.where((notif) => !(notif['isRead'] ?? false)).length;
//
//   // Get notifications by type
//   List<Map<String, dynamic>> getNotificationsByType(String type) {
//     return notifications.where((notif) => notif['type'] == type).toList();
//   }
// }

import 'dart:developer' as developper;

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hotelbilling/app/core/services/session_manager_service.dart';
import 'dart:async';

class NotificationStorageController extends GetxController {
  final storage = GetStorage();
  final notifications = <Map<String, dynamic>>[].obs;
  Timer? cleanupTimer;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Store current user role
  String? _currentUserRole;
  String? _currentUserId;

  static const String NOTIFICATIONS_KEY = 'notifications';
  static const String LAST_CLEANUP_KEY = 'last_cleanup_date';

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
  }

  @override
  void onClose() {
    cleanupTimer?.cancel();
    super.onClose();
  }

  // Initialize user data from TokenManager
  Future<void> _initializeUserData() async {
    try {
      final userData = await TokenManager.getUserData();
      _currentUserRole = userData['userRole'];
      _currentUserId = userData['userId'];

      if (_currentUserRole != null && _currentUserId != null) {
        await loadNotifications();
        checkAndCleanup();
        scheduleNextCleanup();
      } else {
        developper.log('User authentication data missing', name: 'NotificationStorageController');
        errorMessage.value = 'User authentication data not found';
      }
    } catch (e) {
      developper.log('Error initializing user data: $e', name: 'NotificationStorageController');
      errorMessage.value = 'Failed to load user data';
    }
  }

  // Generate role-specific storage key
  String _getRoleSpecificKey(String baseKey) {
    if (_currentUserRole == null || _currentUserId == null) {
      return baseKey;
    }
    return '${baseKey}_${_currentUserRole}_${_currentUserId}';
  }

  // Add new notification when received
  void storeNotification({
    required String title,
    required String body,
    String? payload,
    String? type,
    Map<String, dynamic>? additionalData,
  }) {
    if (_currentUserRole == null || _currentUserId == null) {
      print('⚠️ Cannot store notification: User role/ID not available');

      return;
    }

    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'payload': payload,
      'type': type ?? 'default',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
      'additionalData': additionalData,
      'userRole': _currentUserRole, // Store role with notification
      'userId': _currentUserId, // Store userId with notification
    };

    notifications.insert(0, notification); // Add at top
    saveNotifications();
    print('📥 Notification stored for $_currentUserRole: $title');
  }

  // Save notifications to role-specific storage
  void saveNotifications() {
    if (_currentUserRole == null || _currentUserId == null) {
      print('⚠️ Cannot save notifications: User role/ID not available');
      return;
    }

    final key = _getRoleSpecificKey(NOTIFICATIONS_KEY);
    storage.write(key, notifications.toList());
    print('💾 Notifications saved for $_currentUserRole (Key: $key)');
  }

  // Load notifications from role-specific storage
  Future<void> loadNotifications() async {
    if (_currentUserRole == null || _currentUserId == null) {
      // Try to reload user data
      await _initializeUserData();
      if (_currentUserRole == null || _currentUserId == null) {
        print('⚠️ Cannot load notifications: User role/ID not available');
        return;
      }
    }

    isLoading.value = true;
    try {
      final key = _getRoleSpecificKey(NOTIFICATIONS_KEY);
      final stored = storage.read(key);

      if (stored != null) {
        notifications.value = List<Map<String, dynamic>>.from(stored);
        print('📦 Loaded ${notifications.length} notifications for $_currentUserRole');
      } else {
        notifications.clear();
        print('📦 No notifications found for $_currentUserRole');
      }
      errorMessage.value = '';
    } catch (e) {
      print('❌ Error loading notifications: $e');
      errorMessage.value = 'Failed to load notifications';
      notifications.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Check if cleanup is needed and perform it
  void checkAndCleanup() {
    if (_currentUserRole == null || _currentUserId == null) {
      return;
    }

    final cleanupKey = _getRoleSpecificKey(LAST_CLEANUP_KEY);
    final lastCleanup = storage.read(cleanupKey);
    final now = DateTime.now();

    // Convert to IST
    final istNow = now.toUtc().add(Duration(hours: 5, minutes: 30));

    if (lastCleanup == null) {
      storage.write(cleanupKey, istNow.toIso8601String());
      return;
    }

    final lastCleanupDate = DateTime.parse(lastCleanup);

    // Check if it's a new day and past 6 AM IST
    if (istNow.day != lastCleanupDate.day ||
        istNow.month != lastCleanupDate.month ||
        istNow.year != lastCleanupDate.year) {

      if (istNow.hour >= 6) {
        clearAllNotifications();
        storage.write(cleanupKey, istNow.toIso8601String());
        print('✅ Notifications cleared at 6 AM IST for $_currentUserRole: ${istNow.toString()}');
      }
    }
  }

  // Schedule next cleanup at 6 AM IST
  void scheduleNextCleanup() {
    final now = DateTime.now();
    final istNow = now.toUtc().add(Duration(hours: 5, minutes: 30));

    DateTime nextCleanup;
    if (istNow.hour < 6) {
      nextCleanup = DateTime(istNow.year, istNow.month, istNow.day, 6, 0, 0);
    } else {
      final tomorrow = istNow.add(Duration(days: 1));
      nextCleanup = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 6, 0, 0);
    }

    final nextCleanupLocal = nextCleanup.subtract(Duration(hours: 5, minutes: 30));
    final duration = nextCleanupLocal.difference(now);

    print('⏰ Next cleanup for $_currentUserRole at 6 AM IST in: ${duration.inHours}h ${duration.inMinutes % 60}m');

    cleanupTimer?.cancel();

    cleanupTimer = Timer(duration, () {
      clearAllNotifications();
      final cleanupKey = _getRoleSpecificKey(LAST_CLEANUP_KEY);
      storage.write(cleanupKey, DateTime.now().toUtc().add(Duration(hours: 5, minutes: 30)).toIso8601String());
      print('✅ Scheduled cleanup executed at 6 AM IST for $_currentUserRole');
      scheduleNextCleanup();
    });
  }

  // Clear all notifications for current role
  void clearAllNotifications() {
    if (_currentUserRole == null || _currentUserId == null) {
      return;
    }

    notifications.clear();
    final key = _getRoleSpecificKey(NOTIFICATIONS_KEY);
    storage.remove(key);
    print('🗑️ All notifications cleared for $_currentUserRole');
  }

  // Remove single notification
  void removeNotification(String id) {
    notifications.removeWhere((notif) => notif['id'] == id);
    saveNotifications();
  }

  // Mark notification as read
  void markAsRead(String id) {
    final index = notifications.indexWhere((notif) => notif['id'] == id);
    if (index != -1) {
      notifications[index]['isRead'] = true;
      saveNotifications();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (var notification in notifications) {
      notification['isRead'] = true;
    }
    saveNotifications();
    print('✅ All notifications marked as read for $_currentUserRole');
  }

  // Get unread count
  int get unreadCount => notifications.where((notif) => !(notif['isRead'] ?? false)).length;

  // Get notifications by type
  List<Map<String, dynamic>> getNotificationsByType(String type) {
    return notifications.where((notif) => notif['type'] == type).toList();
  }

  // Get current user role
  String? get currentUserRole => _currentUserRole;

  // Get current user ID
  String? get currentUserId => _currentUserId;

  // Refresh notifications (useful when switching users)
  Future<void> refreshNotifications() async {
    await _initializeUserData();
  }

  // Clear all data for current user (useful on logout)
  Future<void> clearUserNotifications() async {
    if (_currentUserRole == null || _currentUserId == null) {
      return;
    }

    final notificationKey = _getRoleSpecificKey(NOTIFICATIONS_KEY);
    final cleanupKey = _getRoleSpecificKey(LAST_CLEANUP_KEY);

    storage.remove(notificationKey);
    storage.remove(cleanupKey);
    notifications.clear();

    cleanupTimer?.cancel();

    print('🗑️ All data cleared for $_currentUserRole');
  }
}