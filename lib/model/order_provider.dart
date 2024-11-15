import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:frontend/api/user_api.dart';
import 'package:frontend/model/order.dart';
import 'user.dart';

class OrderStatusProvider extends ChangeNotifier {
  bool _isOrderPlaced = false;
  Timer? _countdownTimer;
  Duration _timeUntilCollection = Duration.zero;
  OrderDetails? _orderDetails;

  bool get isOrderPlaced => _isOrderPlaced;
  Duration get timeUntilCollection => _timeUntilCollection;
  OrderDetails? get orderDetails => _orderDetails;

  void placeOrder(OrderDetails orderDetails) {
    _orderDetails = orderDetails;
    _isOrderPlaced = true;
    _startCountdown(orderDetails.listing.availabilityStartDate);
    notifyListeners();
  }

  void _startCountdown(DateTime collectionStart) {
    _countdownTimer?.cancel();
    _updateCountdown(collectionStart); // Immediate countdown update on start
    _countdownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _updateCountdown(collectionStart);
    });
  }

  void _updateCountdown(DateTime collectionStart) {
    final now = DateTime.now();
    _timeUntilCollection = collectionStart.difference(now);
    if (_timeUntilCollection <= Duration.zero) {
      _timeUntilCollection = Duration.zero;
      _countdownTimer?.cancel();
    }
    notifyListeners();
  }

  Future<void> checkForLiveOrders() async {
    try {
      UserAPI userAPI = UserAPI('http://127.0.0.1:5000');
      User? currentUser = await UserService.getUser();
      var liveOrders = await userAPI.getUserLiveOrders(currentUser!);
      if (liveOrders != null && liveOrders.isNotEmpty) {
        _orderDetails = liveOrders.first;
        _isOrderPlaced = true;
        _startCountdown(_orderDetails!.listing.availabilityStartDate);
      } else {
        _isOrderPlaced = false;
        _orderDetails = null;
      }
      notifyListeners();
    } catch (e) {
      // Handle exceptions
      print('Error fetching live orders: $e');
    }
  }

  void orderCollected() {
    _isOrderPlaced = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
