// ✅ Retry state tracker
import 'dart:async';

class RetryState {
  final int orderId;
  final bool isItemsAdded;
  final int maxAttempts;
  int currentAttempt = 0;
  Timer? timer;
  bool isCancelled = false;

  RetryState({
    required this.orderId,
    required this.isItemsAdded,
    required this.maxAttempts,
  });

  void cancel() {
    isCancelled = true;
    timer?.cancel();
    timer = null;
  }
}