class Env {
  static const base = "http://192.168.1.129/iforenta_api"; // عدّلها

  // توكن الأدمن (لو سكربتاتك تحتاجه)
  static const adminToken = "PUT-ADMIN-TOKEN";
  static const uploadImage = "$base/upload_image.php"; // جديد

  // Orders
  static const ordersList =
      "$base/get_pending_orders.php"; // GET ?status=pending
  static const orderUpdate =
      "$base/update_order_status.php"; // POST order_id,status

  // Categories
  static const categoriesList = "$base/get_categories.php"; // GET
  static const categoryAdd =
      "$base/add_category.php"; // POST name,image_url,active
  static const categoryUpdate =
      "$base/update_category.php"; // POST id,name,image_url,active
  static const categoryDelete = "$base/delete_category.php"; // POST id

  // Items
  static const itemsList = "$base/get_items.php";
  static const itemAdd = "$base/add_item.php";
  static const itemUpdate = "$base/update_item.php";
  static const itemDelete = "$base/delete_item.php";

  // Offers
  static const offersList = "$base/get_offers.php";
  static const offerAdd = "$base/add_offer.php";
  static const offerUpdate = "$base/update_offer.php";
  static const offerDelete = "$base/delete_offer.php";

  // Dashboard (لو عندك سكربتات)
  static const stats = "$base/dashboard_stats.php";
  static const mostOrdered = "$base/dashboard/most_ordered.php";
  static const reviews = "$base/dashboard/reviews.php";

  // Users
  static const usersList = "$base/get_user.php";

  // Drivers
  static const driversList = "$base/get_drivers.php";
  static const orderAssignDriver = "$base/assign_driver.php";

  // Admins
  static const loginAdmin = 'http://192.168.1.129/iforenta_api/login_admin.php';
  static const me = 'http://192.168.1.129/iforenta_api/me.php';
  static const addAdmin = 'http://192.168.1.129/iforenta_api/add_admin.php';

  // receivers

  static const receiverLogin = '$base/iforenta_api/login_receiver.php';
  static const ordersInbox = '$base/iforenta_api/orders_inbox.php';
  static const orderSetStatus = '$base/iforenta_api/order_set_status.php';
  static const itemsWithActive =
      '$base/iforenta_api/items_list_with_active.php';
  static const itemToggleActive = '$base/iforenta_api/item_toggle_active.php';
}
