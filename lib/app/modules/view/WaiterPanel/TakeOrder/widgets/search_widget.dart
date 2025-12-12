import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../../../apputils/Utils/common_utils.dart';
import '../../../../controllers/WaiterPanelController/add_item_controller.dart';


class SearchWidget extends StatelessWidget {
  final AddItemsController controller;

  const SearchWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CommonUiUtils.buildTextFormField(
      controller: controller.searchController,
      hint: 'Search by name / code',
      label: 'search',
      icon: PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      onChanged: (value) {
        // Search listener is already set up in controller
      },
    );
  }
}
