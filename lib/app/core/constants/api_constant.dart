class ApiConstants {

  // Base URL
  static const String baseUrl = "https://api-dev.squrepos.com";
  // static const String baseUrl = "https://qb2267h4-3005.inc1.devtunnels.ms";

  //Socket Base URL

  static const String socketBaseUrl = "https://api-dev.squrepos.com";
  // static const String socketBaseUrl = "https://qb2267h4-3005.inc1.devtunnels.ms";

  // Auth
  static const String hostelBillingLogin = "/api/owner/employee/login";

  // Waiter Panel
  static const String waiterGetTable = "/api/owner/employee/tables";

  static String waiterGetTableOrder(int orderId) => "/api/owner/employee/orders/$orderId";

  static const String waiterGetMenuCategory = "/api/owner/employee/get/categories/list";

  static String getCleanerMenuSubcategory(int id) => "/api/owner/employee/menu/category/$id/items";

  static const String waiterPostCreateOrder = "/api/owner/employee/orders/create";

  static String waiterPostReorder(int placedOrderId) => "/api/owner/employee/orders/$placedOrderId/items/add";

  static const String waiterGetReadyToServe = "/api/owner/employee/items/waiter/panel";

  static String waiterPatchOrderUpdate(int orderId,int id) => "/api/owner/employee/orders/$orderId/items/$id/status";

  static const String waiterGetHistory = "/api/owner/employee/orders/get";




  //Chef Panel

  static const String chefGetAllOrder = "/api/owner/employee/items/status/pending";

  static const String chefGetPreparingOrder = "/api/owner/employee/items/status/preparing";

  static String chefPatchOrderUpdate(int orderId,int id) => "/api/owner/employee/orders/$orderId/items/$id/status";

  static String chefPostOrderReject(int orderId,int id) => "/api/owner/employee/orders/$orderId/items/$id/reject";



}
