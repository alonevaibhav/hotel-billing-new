import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/services/storage_service.dart';
import '../../../controllers/chef_drawer_controller.dart';

class ChefDrawerWidget extends StatelessWidget {
  const ChefDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ChefDrawerController controller = Get.put(ChefDrawerController());

    return Drawer(
      backgroundColor: const Color(0xFFFAFAFC),
      child: SafeArea(
        child: Column(
          children: [
            // Enhanced Drawer Header
            _buildDrawerHeader(controller),

            const Gap(8),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildMenuItem(
                    controller: controller,
                    icon: PhosphorIcons.storefront(PhosphorIconsStyle.regular),
                    title: 'Restaurant',
                    isSelected:
                    controller.selectedSidebarItem.value == 'RESTAURANT',
                    onTap: () {
                      controller.handleRestaurant();
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    controller: controller,
                    icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
                    title: 'Notifications',
                    isSelected:
                    controller.selectedSidebarItem.value == 'NOTIFICATION',
                    onTap: () {
                      controller.handleNotification();
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    controller: controller,
                    icon: PhosphorIcons.clockCounterClockwise(
                        PhosphorIconsStyle.regular),
                    title: 'History',
                    isSelected:
                    controller.selectedSidebarItem.value == 'HISTORY',
                    onTap: () {
                      controller.handleHistory();
                      Navigator.pop(context);
                    },
                  ),
                  // _buildMenuItem(
                  //   controller: controller,
                  //   icon: PhosphorIcons.gear(PhosphorIconsStyle.regular),
                  //   title: 'Settings',
                  //   isSelected:
                  //   controller.selectedSidebarItem.value == 'SETTINGS',
                  //   onTap: () {
                  //     controller.handleSettings();
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ],
              ),
            ),

            // Enhanced Footer
            _buildDrawerFooter(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ChefDrawerController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF5B73DF),
            const Color(0xFF4A5FCC),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B73DF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Restaurant Logo with enhanced styling
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              PhosphorIcons.storefront(PhosphorIconsStyle.fill),
              size: 32,
              color: const Color(0xFF5B73DF),
            ),
          ),

          const Gap(20),

          // Restaurant Name
          Text(
            StorageService.to.getOrganizationName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),

          const Gap(6),

          // Restaurant Address with icon
          Row(
            children: [
              Icon(
                PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                size: 12,
                color: Colors.white.withOpacity(0.8),
              ),
              const Gap(4),
              Expanded(
                child: Text(
                  StorageService.to.getOrganizationAddress(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const Gap(16),

          // User Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.chefHat(PhosphorIconsStyle.fill),
                    size: 14,
                    color: const Color(0xFF5B73DF),
                  ),
                ),
                const Gap(8),
                Text(
                  StorageService.to.getUserName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required ChefDrawerController controller,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: const Color(0xFF5B73DF).withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5B73DF).withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? const Color(0xFF5B73DF)
                        : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const Gap(14),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF5B73DF)
                        : Colors.grey.shade700,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5B73DF),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(
      ChefDrawerController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [

          const Gap(8),

          // Logout Button
          _buildFooterButton(
            icon: PhosphorIcons.signOut(PhosphorIconsStyle.regular),
            label: 'Logout',
            color: Colors.red.shade600,
            onPressed: () => _showLogoutDialog(context, controller),
          ),

          const Gap(12),

          // App Version
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIcons.info(PhosphorIconsStyle.fill),
                  size: 10,
                  color: Colors.grey.shade500,
                ),
                const Gap(4),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: color,
                ),
                const Gap(12),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
      BuildContext context, ChefDrawerController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.signOut(PhosphorIconsStyle.fill),
                  size: 28,
                  color: Colors.red.shade600,
                ),
              ),
              const Gap(20),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        controller.handleLogout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}