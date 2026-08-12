class ApiConfig {
  static const String baseUrl = 'https://d100c6f2kgsym4.cloudfront.net';
  static const String apiPrefix = '/api/v1';
  static const Duration timeout = Duration(seconds: 30);

  static const String adminLogin = '$apiPrefix/admin/login';
  static const String adminDashboard = '$apiPrefix/admin/dashboard';
  static const String adminUsers = '$apiPrefix/admin/users';
  static const String adminOrders = '$apiPrefix/admin/orders';
  static String adminOrderStatus(String id) => '$apiPrefix/admin/orders/$id/status';
  static const String adminDelivery = '$apiPrefix/admin/delivery';
  static String adminDeliveryDispatch(String id) => '$apiPrefix/admin/delivery/$id/dispatch';
  static String adminDeliveryVerify(String id) => '$apiPrefix/admin/delivery/$id/verify';
  static String adminDeliveryTracking(String id) => '$apiPrefix/admin/delivery/$id/tracking';
  static const String adminReturns = '$apiPrefix/admin/returns';
  static String adminReturnApprove(String id) => '$apiPrefix/admin/returns/$id/approve';
  static String adminReturnReject(String id) => '$apiPrefix/admin/returns/$id/reject';
  static String adminReturnPickup(String id) => '$apiPrefix/admin/returns/$id/pickup';
  static const String adminProducts = '$apiPrefix/admin/products';
  static String adminProduct(String id) => '$apiPrefix/admin/products/$id';
  static const String adminCategories = '$apiPrefix/admin/categories';
  static String adminCategory(String id) => '$apiPrefix/admin/categories/$id';
  static const String adminCoupons = '$apiPrefix/admin/coupons';
  static String adminCoupon(String id) => '$apiPrefix/admin/coupons/$id';
  static const String adminBanners = '$apiPrefix/admin/banners';
  static String adminBanner(String id) => '$apiPrefix/admin/banners/$id';
  static const String adminPaymentMethods = '$apiPrefix/admin/payment-methods';
  static String adminPaymentMethod(String id) => '$apiPrefix/admin/payment-methods/$id';
  static const String adminDeliverySettings = '$apiPrefix/admin/delivery-settings';
  static const String adminReferralSettings = '$apiPrefix/admin/referral-settings';
  static const String adminReferralPurchases = '$apiPrefix/admin/referral-purchases';
  static String adminReferralApprove(String id) =>
      '$apiPrefix/admin/referral-purchases/$id/approve';
  static String adminReferralReject(String id) =>
      '$apiPrefix/admin/referral-purchases/$id/reject';
  static const String adminReferralUserReport = '$apiPrefix/admin/referral-reports/user';
  static const String adminContactMessages = '$apiPrefix/admin/contact-messages';
  static String adminContactMessage(String id) => '$apiPrefix/admin/contact-messages/$id';
  static String adminContactMessageRead(String id, {bool isRead = true}) =>
      '$apiPrefix/admin/contact-messages/$id/read?is_read=$isRead';
  static const String adminNewsletterSubscribers = '$apiPrefix/admin/newsletter-subscribers';

  // Public endpoints (used for admin list/detail views)
  static const String products = '$apiPrefix/products';
  static const String categories = '$apiPrefix/categories';

  static const String upload = '$apiPrefix/upload';
  static const String refreshToken = '$apiPrefix/auth/refresh-token';
}
