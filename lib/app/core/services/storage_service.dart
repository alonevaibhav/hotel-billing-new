import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;

/// Simple Storage Service for organization data only
class StorageService extends GetxService {

  static StorageService get to => Get.find();

  late GetStorage _box;

  // Storage Keys
  static const String _organizationNameKey = 'organization_name';
  static const String _organizationAddressKey = 'organization_address';
  static const String _userNameKey = 'user_name';

  // Employee Data Keys
  static const String _employeeIdKey = 'employee_id';
  static const String _hotelOwnerIdKey = 'hotel_owner_id';
  static const String _employeeNameKey = 'employee_name';
  static const String _designationKey = 'designation';
  static const String _orgNameKey = 'organization_name';

  /// Initialize storage service
  Future<StorageService> init() async {
    developer.log('Initializing Storage Service', name: 'StorageService');

    await GetStorage.init('app_storage');
    _box = GetStorage('app_storage');

    developer.log('Storage Service initialized', name: 'StorageService');
    return this;
  }

  /// Store organization data - call after successful login
  void storeOrganizationData({
    required String organizationName,
    required String organizationAddress,
    required String userName,
  }) {
    try {
      _box.write(_organizationNameKey, organizationName);
      _box.write(_organizationAddressKey, organizationAddress);
      _box.write(_userNameKey, userName);

      developer.log('Organization data stored: $organizationName', name: 'StorageService');
    } catch (e) {
      developer.log('Failed to store organization data: $e', name: 'StorageService');
    }
  }

  /// Get organization name - call to restore after hot reload
  String getOrganizationName() {
    try {
      final name = _box.read(_organizationNameKey) ?? 'Hotel Name';
      return name;
    } catch (e) {
      developer.log('Failed to get organization name: $e', name: 'StorageService');
      return 'Hotel Name';
    }
  }

  /// Get organization address - call to restore after hot reload
  String getOrganizationAddress() {
    try {
      final address = _box.read(_organizationAddressKey) ?? 'Hotel Address';
      return address;
    } catch (e) {
      developer.log('Failed to get organization address: $e', name: 'StorageService');
      return 'Hotel Address';
    }
  }

  String getUserName() {
    try {
      final userName = _box.read(_userNameKey) ?? 'raju';
      return userName;
    } catch (e) {
      developer.log('Failed to get organization address: $e', name: 'StorageService');
      return 'Hotel Address';
    }
  }

  /// Store employee data for socket connections
  void storeEmployeeData({
    required int userId,
    required int hotelOwnerId,
    required String employeeName,
    required String designation,
    required String organizationName,
  }) {
    try {
      _box.write(_employeeIdKey, userId);
      _box.write(_hotelOwnerIdKey, hotelOwnerId);
      _box.write(_employeeNameKey, employeeName);
      _box.write(_designationKey, designation);
      _box.write(_orgNameKey, organizationName);

      developer.log(
        '✅ Employee data stored: $employeeName ($designation) at $organizationName',
        name: 'StorageService',
      );
    } catch (e) {
      developer.log(
        '❌ Error storing employee data: $e',
        name: 'StorageService.Error',
      );
    }
  }

  /// Get complete employee data as Map (for socket connection)
  Map<String, dynamic>? getEmployeeData() {
    try {
      final userId = _box.read(_employeeIdKey);
      final hotelOwnerId = _box.read(_hotelOwnerIdKey);
      final employeeName = _box.read(_employeeNameKey);
      final designation = _box.read(_designationKey);
      final organizationName = _box.read(_orgNameKey);

      // Check if any data exists
      if (userId == null || hotelOwnerId == null) {
        developer.log(
          '⚠️ No employee data found in storage',
          name: 'StorageService',
        );
        return null;
      }

      final data = {
        'id': userId as int,
        'hotelOwnerId': hotelOwnerId as int,
        'employeeName': employeeName as String? ?? 'User',
        'designation': designation as String? ?? 'waiter',
        'organizationName': organizationName as String? ?? 'Hotel',
      };

      developer.log(
        '✅ Employee data retrieved: ${data['employeeName']} (${data['designation']})',
        name: 'StorageService',
      );

      return data;
    } catch (e) {
      developer.log(
        '❌ Error retrieving employee data: $e',
        name: 'StorageService.Error',
      );
      return null;
    }
  }

  /// Get individual employee fields
  int? get employeeId => _box.read(_employeeIdKey);
  int? get hotelOwnerId => _box.read(_hotelOwnerIdKey);
  String? get employeeName => _box.read(_employeeNameKey);
  String? get designation => _box.read(_designationKey);

  /// Clear employee data
  void clearEmployeeData() {
    try {
      _box.remove(_employeeIdKey);
      _box.remove(_hotelOwnerIdKey);
      _box.remove(_employeeNameKey);
      _box.remove(_designationKey);
      _box.remove(_orgNameKey);

      developer.log(
        '✅ Employee data cleared',
        name: 'StorageService',
      );
    } catch (e) {
      developer.log(
        '❌ Error clearing employee data: $e',
        name: 'StorageService.Error',
      );
    }
  }

  /// Clear organization data - call on logout
  void clearOrganizationData() {
    try {
      _box.remove(_organizationNameKey);
      _box.remove(_organizationAddressKey);
      _box.remove(_userNameKey);

      developer.log('Organization data cleared', name: 'StorageService');
    } catch (e) {
      developer.log('Failed to clear organization data: $e', name: 'StorageService');
    }
  }
}