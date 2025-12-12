import 'package:get/get.dart';

import '../modules/auth/login_view_controller.dart';


class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Register all controllers here

    Get.lazyPut<LoginViewController>(() => LoginViewController(), fenix: true);
  }
}
