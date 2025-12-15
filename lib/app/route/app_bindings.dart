import 'package:get/get.dart';

import '../modules/auth/login_view_controller.dart';
import '../modules/controllers/ChefController/accept_order_controller.dart';
import '../modules/controllers/ChefController/done_order_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Register all controllers here

    Get.lazyPut<LoginViewController>(() => LoginViewController(), fenix: true);

    Get.put<AcceptOrderController>(
      AcceptOrderController(),
      permanent: true,
    );
    Get.put<DoneOrderController>(
      DoneOrderController(),
      permanent: true,
    );


  }
}
