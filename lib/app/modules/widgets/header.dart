import 'package:flutter/material.dart' hide DrawerController;
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/services/storage_service.dart';
import '../controllers/drawer_controller.dart';

class CommonHeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? customTitle;
  final VoidCallback? onBackPressed;
  final bool showDrawerButton;

  const CommonHeaderWidget({
    super.key,
    this.showBackButton = false,
    this.customTitle,
    this.onBackPressed,
    this.showDrawerButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final DrawerController controller = Get.put(DrawerController());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button or Hamburger Menu
            if (showDrawerButton)
              GestureDetector(
                onTap: () {
                  // Find the nearest Scaffold context
                  final scaffoldState = Scaffold.of(context);
                  scaffoldState.openDrawer();
                },
                child: Icon(
                  PhosphorIcons.list(PhosphorIconsStyle.regular),
                  size: 24,
                  color: Colors.black87,
                ),
              ),

            Builder(
              builder: (context) {
                final gap = MediaQuery.of(context).size.width > 800;
                return Gap(gap ? 0 : 16);
              },
            ),

            // Custom Title or Hotel Info
            Expanded(
              child: customTitle != null
                  ? // Show Custom Title
              Text(
                customTitle!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
                  : // Show Hotel Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    StorageService.to.getOrganizationName(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    StorageService.to.getOrganizationAddress(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}