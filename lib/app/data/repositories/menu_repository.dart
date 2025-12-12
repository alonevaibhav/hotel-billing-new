// lib/app/data/repositories/menu_repository.dart

import 'dart:developer' as developer;
import '../../core/constants/api_constant.dart';
import '../../core/services/api_service.dart';
import '../models/ResponseModel/category_model.dart';
import '../models/ResponseModel/subcategory_model.dart';

class MenuRepository {
  /// Fetch all menu categories
  Future<CategoryResponse> getCategories() async {
    try {
      developer.log('Fetching categories from API', name: 'MENU_REPOSITORY');

      final response = await ApiService.get<CategoryResponse>(
        endpoint: ApiConstants.waiterGetMenuCategory,
        fromJson: (json) => CategoryResponse.fromJson(json),
        includeToken: true,
      );

      if (response?.data?.success == true) {
        developer.log(
          'Categories fetched: ${response!.data!.data.length}',
          name: 'MENU_REPOSITORY',
        );
        return response.data!;
      }

      throw Exception('Failed to fetch categories');
    } catch (e) {
      developer.log('Error fetching categories: $e', name: 'MENU_REPOSITORY');
      rethrow;
    }
  }

  /// Fetch menu items for a specific category
  Future<MenuItemResponse> getMenuItemsByCategory(int categoryId) async {
    try {
      developer.log(
        'Fetching items for category ID: $categoryId',
        name: 'MENU_REPOSITORY',
      );

      final response = await ApiService.get<MenuItemResponse>(
        endpoint: ApiConstants.getCleanerMenuSubcategory(categoryId),
        fromJson: (json) => MenuItemResponse.fromJson(json),
        includeToken: true,
      );

      if (response?.data?.success == true) {
        developer.log(
          'Items fetched: ${response!.data!.data.length}',
          name: 'MENU_REPOSITORY',
        );
        return response.data!;
      }

      throw Exception('Failed to fetch menu items');
    } catch (e) {
      developer.log(
        'Error fetching items for category $categoryId: $e',
        name: 'MENU_REPOSITORY',
      );
      rethrow;
    }
  }

  /// Fetch all items across all categories
  Future<List<MenuItemResponse>> getAllMenuItems(
      List<int> categoryIds,
      ) async {
    try {
      final List<MenuItemResponse> allResponses = [];

      for (final categoryId in categoryIds) {
        final response = await getMenuItemsByCategory(categoryId);
        allResponses.add(response);
      }

      developer.log(
        'Fetched items for ${categoryIds.length} categories',
        name: 'MENU_REPOSITORY',
      );

      return allResponses;
    } catch (e) {
      developer.log('Error fetching all menu items: $e', name: 'MENU_REPOSITORY');
      rethrow;
    }
  }
}