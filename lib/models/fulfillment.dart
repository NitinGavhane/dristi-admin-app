class FulfillmentUser {
  final String id;
  final String fullName;
  final String email;
  final String? phone;

  FulfillmentUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
  });

  factory FulfillmentUser.fromJson(Map<String, dynamic> json) {
    return FulfillmentUser(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
    );
  }
}

class FulfillmentItem {
  final String id;
  final String productName;
  final int quantity;
  final double price;

  FulfillmentItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory FulfillmentItem.fromJson(Map<String, dynamic> json) {
    return FulfillmentItem(
      id: json['id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Admin-facing order envelope for the delivery / returns dashboards.
class FulfillmentOrder {
  final String id;
  final String orderNumber;
  final FulfillmentUser user;
  final String orderStatus;
  final String paymentStatus;
  final String? returnStatus;
  final String? returnReason;
  final String? returnAdminNote;
  final String? shippingAddress;
  final double finalAmount;
  final DateTime? createdAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final List<String> returnEvidence;
  final List<FulfillmentItem> items;
  // ShipRocket courier tracking (populated once the order is dispatched).
  final String? awbCode;
  final String? courierName;
  final String? shipmentStatus;
  final String? trackingUrl;

  FulfillmentOrder({
    required this.id,
    required this.orderNumber,
    required this.user,
    required this.orderStatus,
    required this.paymentStatus,
    this.returnStatus,
    this.returnReason,
    this.returnAdminNote,
    this.shippingAddress,
    required this.finalAmount,
    this.createdAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.returnEvidence = const [],
    this.items = const [],
    this.awbCode,
    this.courierName,
    this.shipmentStatus,
    this.trackingUrl,
  });

  factory FulfillmentOrder.fromJson(Map<String, dynamic> json) {
    return FulfillmentOrder(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? '',
      user: FulfillmentUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      orderStatus: json['order_status'] as String? ?? 'placed',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      returnStatus: json['return_status'] as String?,
      returnReason: json['return_reason'] as String?,
      returnAdminNote: json['return_admin_note'] as String?,
      shippingAddress: json['shipping_address'] as String?,
      finalAmount: (json['final_amount'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      dispatchedAt: json['dispatched_at'] != null ? DateTime.tryParse(json['dispatched_at'] as String) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'] as String) : null,
      returnEvidence: (json['return_evidence'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => FulfillmentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      awbCode: json['awb_code'] as String?,
      courierName: json['courier_name'] as String?,
      shipmentStatus: json['shipment_status'] as String?,
      trackingUrl: json['tracking_url'] as String?,
    );
  }

  bool get needsDispatch => orderStatus == 'placed' || orderStatus == 'processing';
  bool get inTransit => orderStatus == 'dispatched' || orderStatus == 'out_for_delivery';
  bool get hasPendingReturn => returnStatus == 'requested' || returnStatus == 'replace_requested';
  bool get returnApproved => returnStatus == 'approved';
}
