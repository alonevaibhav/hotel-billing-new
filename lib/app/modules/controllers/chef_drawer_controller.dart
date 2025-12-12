import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../route/app_routes.dart';
import '../auth/login_view_controller.dart';

class ChefDrawerController extends GetxController {
  // Reactive variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isDrawerOpen = false.obs;

  // Restaurant data
  final restaurantData = Rxn<Map<String, dynamic>>();

  // Hotel information
  final hotelName = 'Alpani Hotel'.obs;
  final hotelAddress = '2672 Westheimer Rd. Santa Ana, Illinois 85486'.obs;
  final phoneNumber = 'Tel: (406) 555-0120'.obs;

  // Selection states
  final selectedMainButton = 'take_orders'.obs;
  final selectedSidebarItem = 'RESTAURANT'.obs;

  @override
  void onInit() {
    super.onInit();
    developer.log('RestaurantController initialized', name: 'Restaurant');
    _initializeData();
  }

  @override
  void onReady() {
    super.onReady();
    developer.log('RestaurantController ready', name: 'Restaurant');
  }

  @override
  void onClose() {
    super.onClose();
    developer.log('RestaurantController disposed', name: 'Restaurant');
  }

  void _initializeData() {
    restaurantData.value = {
      'name': hotelName.value,
      'address': hotelAddress.value,
      'phone': phoneNumber.value,
    };
    developer.log('Restaurant data initialized', name: 'Restaurant');
  }

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
    developer.log('Drawer toggled: ${isDrawerOpen.value}', name: 'Restaurant');
  }

  void handleLogout() {
    developer.log('Logout button pressed', name: 'Restaurant');
    final loginController = Get.find<LoginViewController>();
    loginController.logout();
  }

  void handleNotification() {
    selectedSidebarItem.value = 'NOTIFICATION';
    developer.log('Notification menu pressed', name: 'Restaurant');
    Get.snackbar('Info', 'Notifications feature will be implemented');
  }

  void handleHistory() {
    selectedSidebarItem.value = 'HISTORY';
    developer.log('History menu pressed', name: 'Restaurant');
    NavigationService.pushToChefHistory();
  }

  void handleSettings() {
    selectedSidebarItem.value = 'SETTINGS';
    developer.log('Settings menu pressed', name: 'Restaurant');
    Get.snackbar('Info', 'Settings feature will be implemented');
  }

  void handleRestaurant() {
    selectedSidebarItem.value = 'RESTAURANT';
    developer.log('Restaurant menu pressed', name: 'Restaurant');
  }

  void handleTakeOrders() {
    selectedMainButton.value = 'take_orders';
  }

  void handleReadyOrders() {
    selectedMainButton.value = 'ready_orders';
  }

  void refreshData() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      _initializeData();
      isLoading.value = false;
      Get.snackbar('Success', 'Data refreshed successfully');
    });
  }

  void showError(String message) {
    errorMessage.value = message;
    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }
}
