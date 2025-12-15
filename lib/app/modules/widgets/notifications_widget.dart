import 'dart:developer' as developer;
import '../../core/services/notification_service.dart';
import '../../data/models/ResponseModel/pending_orders_model.dart';

final notificationService = NotificationService.instance;

Future<void> showOrderNotification({
  required int orderId,
  required String tableNumber,
  required int itemCount,
  required bool isNewOrder,
}) async {
  try {

    final title = isNewOrder
        ? '🎉 Order Placed Successfully'
        : '✅ Items Added to Order';

    final body = isNewOrder
        ? 'Order Placed for Table $tableNumber with $itemCount ${itemCount == 1 ? 'item' : 'items'}'
        : '$itemCount new ${itemCount == 1 ? 'item' : 'items'} added (Table $tableNumber)';

    final bigText = isNewOrder
        ? 'Your order has been successfully placed for Table $tableNumber. Total items: $itemCount. The kitchen has been notified and will start preparing your order shortly.'
        : 'Successfully added $itemCount new ${itemCount == 1 ? 'item' : 'items'}  for Table $tableNumber. The kitchen has been notified about the additional items.';

    await notificationService.showBigTextNotification(
      title: title,
      body: body,
      bigText: bigText,
      payload: 'order_$orderId',
      priority: NotificationPriority.high,
    );

    developer.log(
      'Notification shown for order #$orderId',
      name: 'ORDER_NOTIFICATION',
    );
  } catch (e) {
    developer.log(
      'Failed to show notification: $e',
      name: 'ORDER_NOTIFICATION',
    );
    // Don't throw - notification failure shouldn't break the order flow
  }
}



Future<void> showReadyToServeNotification(int orderId, String tableNumber) async {
  try {
    await notificationService.showBigTextNotification(
      title: '🍽️ Order Ready to Serve',
      body: 'Order #$orderId is ready for Table $tableNumber',
      bigText: 'The kitchen has finished preparing Order #$orderId for Table $tableNumber. Please serve the order to the customer.',
      payload: 'ready_order_$orderId',
      priority: NotificationPriority.high,
    );

    developer.log(
      'Ready to serve notification shown for order #$orderId',
      name: 'ReadyOrders.Notification',
    );
  } catch (e) {
    developer.log(
      'Failed to show ready notification: $e',
      name: 'ReadyOrders.Notification',
    );
  }
}

Future<void> showOrderServedNotification(int orderId, String tableNumber) async {
  try {
    await notificationService.showBigTextNotification(
      title: '✅ Order Served',
      body: 'Order #$orderId served to Table $tableNumber',
      bigText: 'Order #$orderId has been successfully served to Table $tableNumber. The order is now marked as served.',
      payload: 'served_order_$orderId',
    );

    developer.log(
      'Order served notification shown for order #$orderId',
      name: 'ReadyOrders.Notification',
    );
  } catch (e) {
    developer.log(
      'Failed to show served notification: $e',
      name: 'ReadyOrders.Notification',
    );
  }
}

Future<void> showOrderCompletedNotification(int orderId, String tableNumber) async {
  try {
    await notificationService.showBigTextNotification(
      title: '🎉 Order Completed',
      body: 'Order #$orderId completed for Table $tableNumber',
      bigText: 'Order #$orderId for Table $tableNumber has been completed. Thank you for your service!',
      payload: 'completed_order_$orderId',
      priority: NotificationPriority.low,
    );

    developer.log(
      'Order completed notification shown for order #$orderId',
      name: 'ReadyOrders.Notification',
    );
  } catch (e) {
    developer.log(
      'Failed to show completed notification: $e',
      name: 'ReadyOrders.Notification',
    );
  }
}



///// WAITER NOTIFICATIONS //////


/// 🔔 Show notification for grouped order
Future<void> showGroupedOrderNotification({
  required GroupedOrder groupedOrder,
  bool isItemsAdded = false,
}) async {
  try {
    final title = isItemsAdded
        ? '✅ Items Added to Order'
        : '🎉 New Order Received';

    final itemCount = groupedOrder.totalItemsCount;
    final itemNames = groupedOrder.items
        .map((item) => '${item.quantity}x ${item.itemName}')
        .take(5) // Show max 5 items in notification
        .join(', ');

    final moreItems = groupedOrder.items.length > 5
        ? ' and ${groupedOrder.items.length - 5} more...'
        : '';

    final body = isItemsAdded
        ? 'Order #${groupedOrder.orderId} - Table ${groupedOrder.tableNumber}'
        : 'Order #${groupedOrder.orderId} - Table ${groupedOrder.tableNumber} - $itemCount ${itemCount == 1 ? 'item' : 'items'}';

    final bigText = isItemsAdded
        ? 'Items added to Order #${groupedOrder.orderId} for Table ${groupedOrder.tableNumber}:\n\n'
        '$itemNames$moreItems\n\n'
        : 'New order received for Table ${groupedOrder.tableNumber}:\n\n'
        '$itemNames$moreItems\n\n'
        'Total items: $itemCount\n'
        'Please review and accept the order to start preparation.';

    await notificationService.showBigTextNotification(
      title: title,
      body: body,
      bigText: bigText,
      payload: 'pending_order_${groupedOrder.orderId}',
      priority: NotificationPriority.high,
    );

    developer.log(
      'Grouped notification shown for order #${groupedOrder.orderId}',
      name: 'AcceptOrderController.Notification',
    );
  } catch (e) {
    developer.log(
      'Failed to show grouped notification: $e',
      name: 'AcceptOrderController.Notification',
    );
  }
}

/// 🚫 Show notification for cancelled order
Future<void> showOrderCancelledNotification({
  required int orderId,
  required String orderNumber,
  required String cancelledBy,
  String? tableNumber,
  int affectedItemsCount = 0,
}) async {
  try {
    final title = '🚫 Order Cancelled';

    final body = tableNumber != null && tableNumber.isNotEmpty
        ? 'Order $orderNumber (Table $tableNumber) was cancelled'
        : 'Order $orderNumber was cancelled';

    final bigText = '''
Order Cancelled ❌

Order: $orderNumber
${tableNumber != null && tableNumber.isNotEmpty ? 'Table: $tableNumber\n' : ''}Cancelled By: $cancelledBy
Affected Items: $affectedItemsCount

Please stop preparation immediately.
''';

    await notificationService.showBigTextNotification(
      title: title,
      body: body,
      bigText: bigText,
      payload: 'order_cancelled_$orderId',
      priority: NotificationPriority.high,
    );

    developer.log(
      '🚫 Cancellation notification shown for order #$orderId',
      name: 'AcceptOrderController.Notification',
    );
  } catch (e) {
    developer.log(
      '❌ Failed to show order cancelled notification: $e',
      name: 'AcceptOrderController.Notification',
    );
  }
}

