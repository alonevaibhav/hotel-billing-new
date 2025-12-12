import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/notification_storage_service.dart';
import '../../../../state/app_initial_state.dart';

class WaiterNotificationPage extends StatelessWidget {
  final NotificationStorageController controller = Get.find();

  WaiterNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadNotifications();   // called only once
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() {
              final role = controller.currentUserRole ?? 'User';
              return Text(
                '${controller.notifications.length} total • ${role.capitalize}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              );
            }),
          ],
        ),
        actions: [
          Obx(() {
            final unreadCount = controller.unreadCount;
            if (unreadCount > 0) {
              return TextButton.icon(
                onPressed: () => _markAllAsRead(context),
                icon: Icon(Icons.done_all, size: 18),
                label: Text('Mark all read'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                ),
              );
            }
            return SizedBox.shrink();
          }),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'clear') {
                _showClearDialog(context);
              } else if (value == 'refresh') {
                _refreshNotifications(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blue[700], size: 20),
                    SizedBox(width: 12),
                    Text('Refresh'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red[700], size: 20),
                    SizedBox(width: 12),
                    Text('Clear all', style: TextStyle(color: Colors.red[700])),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: AsyncStateBuilder<NotificationStorageController>(
        controller: controller,
        isLoading: controller.isLoading,
        errorMessage: controller.errorMessage,
        observeData: [controller.notifications],
        isEmpty: (ctrl) => ctrl.notifications.isEmpty,
        onRefresh: () async {
          await controller.loadNotifications();
          await Future.delayed(Duration(milliseconds: 500));
        },
        emptyStateText: 'No notifications yet',
        loadingText: 'Loading notifications...',
        builder: (ctrl) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: ctrl.notifications.length,
            itemBuilder: (context, index) {
              final notification = ctrl.notifications[index];
              return _buildNotificationCard(context, notification, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notification, int index) {
    final isRead = notification['isRead'] ?? false;
    final title = notification['title'] ?? 'Notification';
    final body = notification['body'] ?? '';
    final timestamp = notification['timestamp'] as int?;
    final type = notification['type'] ?? 'default';
    final notificationId = notification['id'] as String;
    final userRole = notification['userRole'] ?? 'unknown';

    return Dismissible(
      key: Key(notificationId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        final removedNotification = notification;
        controller.removeNotification(notificationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification deleted'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Re-add notification at the same position
                controller.notifications.insert(index, removedNotification);
                controller.saveNotifications();
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? Colors.grey[200]! : Colors.blue[100]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (!isRead) {
                controller.markAsRead(notificationId);
              }
              _showNotificationDetails(context, notification);
            },
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon based on notification type
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getTypeIcon(type),
                      color: _getTypeColor(type),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        if (body.isNotEmpty) ...[
                          SizedBox(height: 6),
                          Text(
                            body,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatTimestamp(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getTypeColor(type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getTypeColor(type),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'low':
        return Icons.info_outline_rounded;
      case 'big_text':
        return Icons.article_outlined;
      case 'order':
        return Icons.receipt_long;
      case 'table':
        return Icons.table_restaurant;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'low':
        return Colors.green;
      case 'big_text':
        return Colors.purple;
      case 'order':
        return Colors.orange;
      case 'table':
        return Colors.teal;
      case 'alert':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null) return 'Just now';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTypeColor(notification['type'] ?? 'default').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(notification['type'] ?? 'default'),
                    color: _getTypeColor(notification['type'] ?? 'default'),
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'Notification',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'For ${(notification['userRole'] ?? 'user').toString().capitalize}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              notification['body'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  _formatTimestamp(notification['timestamp']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.removeNotification(notification['id']);
                    },
                    icon: Icon(Icons.delete_outline),
                    label: Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red[300]!),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.check),
                    label: Text('Got it'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _markAllAsRead(BuildContext context) {
    controller.markAllAsRead();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _refreshNotifications(BuildContext context) async {
    await controller.refreshNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications refreshed'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            SizedBox(width: 12),
            Text('Clear All Notifications?'),
          ],
        ),
        content: Text(
          'This will permanently delete all your notifications. This action cannot be undone.',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearAllNotifications();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All notifications cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}