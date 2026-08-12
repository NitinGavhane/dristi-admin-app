import 'dart:typed_data';

import '../config/api_config.dart';
import '../models/dashboard.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/order.dart';
import '../models/coupon.dart';
import '../models/banner.dart';
import '../models/payment_method.dart';
import '../models/contact.dart';
import '../models/delivery_settings.dart';
import '../models/referral.dart';
import '../models/fulfillment.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _api;

  AdminService(this._api);

  Future<void> login(String email, String password) async {
    final response = await _api.post(
      ApiConfig.adminLogin,
      data: {'email': email, 'password': password},
    );
    final data = response.data;
    await _api.setTokens(data['access_token'], data['refresh_token']);
  }

  Future<DashboardStats> getDashboard() async {
    final response = await _api.get(ApiConfig.adminDashboard);
    return DashboardStats.fromJson(response.data);
  }

  Future<List<AdminUser>> getUsers() async {
    final response = await _api.get(ApiConfig.adminUsers);
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['users'] ?? []);
    return data
        .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Products
  Future<List<AdminProduct>> getProducts({
    String? category,
    String? search,
    String? sort,
    String? gender,
  }) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    if (search != null) params['search'] = search;
    if (sort != null) params['sort'] = sort;
    if (gender != null) params['gender'] = gender;

    final response = await _api.get(
      ApiConfig.adminProducts,
      queryParams: params.isNotEmpty ? params : null,
    );
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['products'] ?? []);
    return data
        .map((e) => AdminProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminProduct> getProduct(String id) async {
    final response = await _api.get(ApiConfig.adminProduct(id));
    return AdminProduct.fromJson(response.data);
  }

  Future<AdminProduct> createProduct(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.adminProducts, data: data);
    return AdminProduct.fromJson(response.data);
  }

  Future<AdminProduct> updateProduct(
      String id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.adminProduct(id), data: data);
    return AdminProduct.fromJson(response.data);
  }

  // Delivery settings (store-wide)
  Future<DeliverySettings> getDeliverySettings() async {
    final response = await _api.get(ApiConfig.adminDeliverySettings);
    return DeliverySettings.fromJson(response.data);
  }

  Future<DeliverySettings> updateDeliverySettings(Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.adminDeliverySettings, data: data);
    return DeliverySettings.fromJson(response.data);
  }

  // Refer & earn: programme settings, the approval queue, and per-referrer totals.
  Future<ReferralSettings> getReferralSettings() async {
    final response = await _api.get(ApiConfig.adminReferralSettings);
    return ReferralSettings.fromJson(response.data);
  }

  Future<ReferralSettings> updateReferralSettings(Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.adminReferralSettings, data: data);
    return ReferralSettings.fromJson(response.data);
  }

  Future<List<ReferralPurchase>> getReferralPurchases({String? status}) async {
    final response = await _api.get(
      ApiConfig.adminReferralPurchases,
      queryParams: status != null ? {'status': status} : null,
    );
    return (response.data as List)
        .map((e) => ReferralPurchase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Approve a commission. Sending [rewardAmount] pays exactly that; otherwise
  /// the backend works it out from [rewardPercentage] of the purchase.
  Future<void> approveReferral(String id,
      {required double rewardPercentage, double? rewardAmount}) async {
    await _api.put(ApiConfig.adminReferralApprove(id), data: {
      'reward_percentage': rewardPercentage,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
    });
  }

  Future<void> rejectReferral(String id) async {
    await _api.put(ApiConfig.adminReferralReject(id));
  }

  Future<List<ReferralUserReport>> getReferralUserReport() async {
    final response = await _api.get(ApiConfig.adminReferralUserReport);
    return (response.data as List)
        .map((e) => ReferralUserReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Website enquiries and newsletter signups. The store's domain has no
  // mailbox, so this screen is how the seller actually receives them.
  Future<List<ContactMessage>> getContactMessages() async {
    final response = await _api.get(ApiConfig.adminContactMessages);
    return (response.data as List)
        .map((e) => ContactMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markContactMessageRead(String id, {bool isRead = true}) async {
    await _api.put(ApiConfig.adminContactMessageRead(id, isRead: isRead));
  }

  Future<void> deleteContactMessage(String id) async {
    await _api.delete(ApiConfig.adminContactMessage(id));
  }

  Future<List<NewsletterSubscriber>> getNewsletterSubscribers() async {
    final response = await _api.get(ApiConfig.adminNewsletterSubscribers);
    return (response.data as List)
        .map((e) => NewsletterSubscriber.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete(ApiConfig.adminProduct(id));
  }

  // Categories
  Future<List<AdminCategory>> getCategories({String? gender}) async {
    final params = <String, dynamic>{};
    if (gender != null) params['gender'] = gender;

    try {
      final response = await _api.get(
        ApiConfig.adminCategories,
        queryParams: params.isNotEmpty ? params : null,
      );
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['categories'] ?? response.data['data'] ?? []);
      if (data.isNotEmpty) {
        return data
            .map((e) => AdminCategory.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    final response = await _api.get(
      ApiConfig.categories,
      queryParams: params.isNotEmpty ? params : null,
    );
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['categories'] ?? []);
    return data
        .map((e) => AdminCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminCategory> getCategory(String id) async {
    final response = await _api.get(ApiConfig.adminCategory(id));
    return AdminCategory.fromJson(response.data);
  }

  Future<AdminCategory> createCategory(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.adminCategories, data: data);
    return AdminCategory.fromJson(response.data);
  }

  Future<AdminCategory> updateCategory(
      String id, Map<String, dynamic> data) async {
    final response =
        await _api.put(ApiConfig.adminCategory(id), data: data);
    return AdminCategory.fromJson(response.data);
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete(ApiConfig.adminCategory(id));
  }

  // Orders
  Future<List<AdminOrder>> getOrders() async {
    final response = await _api.get(ApiConfig.adminOrders);
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['orders'] ?? []);
    return data
        .map((e) => AdminOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _api.put(
      ApiConfig.adminOrderStatus(orderId),
      data: {'status': status},
    );
  }

  // Fulfilment: dispatch + delivery OTP, and the returns queue.
  Future<List<FulfillmentOrder>> getDeliveryOrders() async {
    final response = await _api.get(ApiConfig.adminDelivery);
    return (response.data as List)
        .map((e) => FulfillmentOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Dispatches the order; returns the delivery OTP the operator relays to the
  /// customer. The OTP is not stored in the model — it is a one-time relay.
  Future<Map<String, dynamic>> dispatchOrder(String orderId) async {
    final response = await _api.post(ApiConfig.adminDeliveryDispatch(orderId));
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> verifyDeliveryOtp(String orderId, String otp) async {
    await _api.post(ApiConfig.adminDeliveryVerify(orderId), data: {'otp': otp});
  }

  /// Live ShipRocket tracking for an in-transit order (fresh AWB status).
  Future<Map<String, dynamic>> getDeliveryTracking(String orderId) async {
    final response = await _api.get(ApiConfig.adminDeliveryTracking(orderId));
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<List<FulfillmentOrder>> getReturnOrders() async {
    final response = await _api.get(ApiConfig.adminReturns);
    return (response.data as List)
        .map((e) => FulfillmentOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Approves a return; returns the pickup OTP for relaying to the customer.
  Future<Map<String, dynamic>> approveReturn(String orderId) async {
    final response = await _api.post(ApiConfig.adminReturnApprove(orderId));
    return (response.data as Map<String, dynamic>?) ?? {};
  }

  Future<void> rejectReturn(String orderId, String reason) async {
    await _api.post(ApiConfig.adminReturnReject(orderId), data: {'reason': reason});
  }

  Future<void> verifyReturnPickup(String orderId, String otp) async {
    await _api.post(ApiConfig.adminReturnPickup(orderId), data: {'otp': otp});
  }

  // Coupons
  Future<List<AdminCoupon>> getCoupons() async {
    final response = await _api.get(ApiConfig.adminCoupons);
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['coupons'] ?? []);
    return data
        .map((e) => AdminCoupon.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminCoupon> getCoupon(String id) async {
    final response = await _api.get(ApiConfig.adminCoupon(id));
    return AdminCoupon.fromJson(response.data);
  }

  Future<AdminCoupon> createCoupon(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.adminCoupons, data: data);
    return AdminCoupon.fromJson(response.data);
  }

  Future<AdminCoupon> updateCoupon(
      String id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.adminCoupon(id), data: data);
    return AdminCoupon.fromJson(response.data);
  }

  Future<void> deleteCoupon(String id) async {
    await _api.delete(ApiConfig.adminCoupon(id));
  }

  // Banners
  Future<List<AdminBanner>> getBanners() async {
    final response = await _api.get(ApiConfig.adminBanners);
    final List<dynamic> data = response.data is List
        ? response.data
        : (response.data['banners'] ?? response.data['data'] ?? []);
    return data
        .map((e) => AdminBanner.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminBanner> getBanner(String id) async {
    final response = await _api.get(ApiConfig.adminBanner(id));
    return AdminBanner.fromJson(response.data);
  }

  Future<AdminBanner> createBanner(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.adminBanners, data: data);
    return AdminBanner.fromJson(response.data);
  }

  Future<AdminBanner> updateBanner(String id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.adminBanner(id), data: data);
    return AdminBanner.fromJson(response.data);
  }

  Future<void> deleteBanner(String id) async {
    await _api.delete(ApiConfig.adminBanner(id));
  }

  Future<List<AdminPaymentMethod>> getPaymentMethods() async {
    final response = await _api.get(ApiConfig.adminPaymentMethods);
    return (response.data as List).map((e) => AdminPaymentMethod.fromJson(e)).toList();
  }

  Future<AdminPaymentMethod> getPaymentMethod(String id) async {
    final response = await _api.get(ApiConfig.adminPaymentMethod(id));
    return AdminPaymentMethod.fromJson(response.data);
  }

  Future<AdminPaymentMethod> createPaymentMethod(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.adminPaymentMethods, data: data);
    return AdminPaymentMethod.fromJson(response.data);
  }

  Future<AdminPaymentMethod> updatePaymentMethod(String id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.adminPaymentMethod(id), data: data);
    return AdminPaymentMethod.fromJson(response.data);
  }

  Future<void> deletePaymentMethod(String id) async {
    await _api.delete(ApiConfig.adminPaymentMethod(id));
  }

  Future<String> uploadImage(String filePath, {String folder = 'banners'}) async {
    return _api.uploadFile(filePath, folder: folder);
  }

  Future<String> uploadImageBytes(Uint8List bytes, String filename, {String folder = 'banners'}) async {
    return _api.uploadBytes(bytes, filename, folder: folder);
  }
}
