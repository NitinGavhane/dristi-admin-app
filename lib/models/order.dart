class AdminOrderItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  AdminOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}

class AdminOrder {
  final String id;
  final String orderNumber;
  final String userId;
  final double subtotal;
  final double gstAmount;
  final double discountAmount;
  final double finalAmount;
  final String orderStatus;
  final String paymentStatus;
  final String? shippingAddress;
  final List<AdminOrderItem> items;
  final DateTime? createdAt;

  AdminOrder({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.subtotal,
    required this.gstAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.orderStatus,
    required this.paymentStatus,
    this.shippingAddress,
    this.items = const [],
    this.createdAt,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      gstAmount: (json['gst_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      finalAmount: (json['final_amount'] as num).toDouble(),
      orderStatus: json['order_status'] as String,
      paymentStatus: json['payment_status'] as String,
      shippingAddress: json['shipping_address'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => AdminOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  String get statusDisplay {
    switch (orderStatus) {
      case 'pending_payment':
        return 'Awaiting Payment';
      case 'placed':
        return 'Placed';
      case 'processing':
        return 'Processing';
      case 'dispatched':
        return 'Dispatched';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return orderStatus;
    }
  }
}

const List<String> orderStatuses = [
  'placed',
  'processing',
  'dispatched',
  'out_for_delivery',
  'delivered',
  'cancelled',
];
