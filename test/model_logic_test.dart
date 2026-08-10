import 'package:flutter_test/flutter_test.dart';

import 'package:garment_frontend/models/order.dart';
import 'package:garment_frontend/models/delivery_settings.dart';
import 'package:garment_frontend/models/coupon.dart';
import 'package:garment_frontend/models/referral.dart';
import 'package:garment_frontend/models/dashboard.dart';

void main() {
  group('AdminOrder parsing + status display', () {
    test('fromJson maps the full API payload', () {
      final o = AdminOrder.fromJson({
        'id': 'o1',
        'order_number': 'ORD-20260810-XWL74F',
        'user_id': 'u1',
        'subtotal': 1000,
        'gst_amount': 180,
        'discount_amount': 0,
        'final_amount': 1180,
        'order_status': 'out_for_delivery',
        'payment_status': 'paid',
        'shipping_address': 'Bengaluru',
        'items': [
          {'id': 'i1', 'product_id': 'p1', 'product_name': 'Saree', 'quantity': 2, 'price': 500},
        ],
        'created_at': '2026-08-10T10:00:00Z',
      });
      expect(o.orderNumber, 'ORD-20260810-XWL74F');
      expect(o.finalAmount, 1180);
      expect(o.items.length, 1);
      expect(o.items.first.quantity, 2);
      expect(o.items.first.price, 500);
      expect(o.createdAt, isNotNull);
      expect(o.statusDisplay, 'Out for Delivery');
    });

    test('fromJson tolerates missing items/created_at', () {
      final o = AdminOrder.fromJson({
        'id': 'o2',
        'order_number': 'ORD-1',
        'user_id': 'u1',
        'subtotal': 0,
        'gst_amount': 0,
        'discount_amount': 0,
        'final_amount': 0,
        'order_status': 'placed',
        'payment_status': 'pending',
      });
      expect(o.items, isEmpty);
      expect(o.createdAt, isNull);
    });

    test('statusDisplay maps every backend status', () {
      final make = (String s) => AdminOrder(
            id: 'x',
            orderNumber: 'n',
            userId: 'u',
            subtotal: 0,
            gstAmount: 0,
            discountAmount: 0,
            finalAmount: 0,
            orderStatus: s,
            paymentStatus: 'pending',
          );
      expect(make('placed').statusDisplay, 'Placed');
      expect(make('processing').statusDisplay, 'Processing');
      expect(make('dispatched').statusDisplay, 'Dispatched');
      expect(make('out_for_delivery').statusDisplay, 'Out for Delivery');
      expect(make('delivered').statusDisplay, 'Delivered');
      expect(make('cancelled').statusDisplay, 'Cancelled');
      expect(make('unknown_status').statusDisplay, 'unknown_status');
    });

    test('orderStatuses is the canonical status list', () {
      expect(orderStatuses, ['placed', 'processing', 'dispatched', 'out_for_delivery', 'delivered', 'cancelled']);
    });
  });

  group('DeliverySettings', () {
    test('fromJson full payload', () {
      final s = DeliverySettings.fromJson({'enabled': true, 'fee': 49.0, 'free_above': 999.0});
      expect(s.enabled, true);
      expect(s.fee, 49.0);
      expect(s.freeAbove, 999.0);
    });

    test('fromJson defaults to disabled + zero fee when missing', () {
      final s = DeliverySettings.fromJson({});
      expect(s.enabled, false);
      expect(s.fee, 0.0);
      expect(s.freeAbove, isNull);
    });
  });

  group('AdminCoupon', () {
    test('fromJson uses percentage defaults when fields omitted', () {
      final c = AdminCoupon.fromJson({'id': 'c1', 'code': 'SAVE10', 'value': 10});
      expect(c.type, 'percentage');
      expect(c.value, 10);
      expect(c.usageLimit, 100);
      expect(c.usedCount, 0);
      expect(c.isActive, true);
      expect(c.minOrderAmount, isNull);
      expect(c.maxDiscount, isNull);
    });

    test('fromJson full payload', () {
      final c = AdminCoupon.fromJson({
        'id': 'c1',
        'code': 'FLAT50',
        'type': 'fixed',
        'value': 50,
        'min_order_amount': 500,
        'max_discount': 50,
        'expiry_date': '2026-12-31',
        'usage_limit': 25,
        'used_count': 3,
        'is_active': false,
      });
      expect(c.type, 'fixed');
      expect(c.minOrderAmount, 500);
      expect(c.maxDiscount, 50);
      expect(c.usageLimit, 25);
      expect(c.usedCount, 3);
      expect(c.isActive, false);
      expect(c.expiryDate, '2026-12-31');
    });
  });

  group('Referral models', () {
    test('ReferralSettings default commission is 5%', () {
      expect(const ReferralSettings().commissionPercentage, 5.0);
      expect(const ReferralSettings().enabled, true);
    });

    test('ReferralSettings.fromJson honours overrides', () {
      final s = ReferralSettings.fromJson({'enabled': false, 'commission_percentage': 7.5});
      expect(s.enabled, false);
      expect(s.commissionPercentage, 7.5);
    });

    test('ReferralPurchase.fromJson full payload + isPending', () {
      final p = ReferralPurchase.fromJson({
        'id': 'r1',
        'referrer_name': 'Gavhane',
        'referrer_email': 'g@x.com',
        'referrer_code': 'CODE99',
        'referred_user_name': 'Buyer',
        'referred_user_email': 'b@x.com',
        'product_name': 'Saree',
        'order_id': 'o1',
        'order_number': 'ORD-1',
        'purchase_amount': 1000,
        'reward_amount': 50,
        'reward_percentage': 5,
        'status': 'pending',
      });
      expect(p.referrerCode, 'CODE99');
      expect(p.rewardAmount, 50);
      expect(p.isPending, true);
    });

    test('ReferralPurchase.fromJson defaults', () {
      final p = ReferralPurchase.fromJson({'id': 'r2'});
      expect(p.referrerName, 'Unknown');
      expect(p.status, 'pending');
      expect(p.purchaseAmount, 0);
      expect(p.rewardAmount, 0);
      expect(p.isPending, true);
    });

    test('ReferralPurchase non-pending statuses', () {
      expect(ReferralPurchase.fromJson({'id': 'r3', 'status': 'approved'}).isPending, false);
      expect(ReferralPurchase.fromJson({'id': 'r4', 'status': 'rejected'}).isPending, false);
    });

    test('ReferralUserReport.fromJson defaults', () {
      final r = ReferralUserReport.fromJson({'user_id': 'u1'});
      expect(r.userName, '');
      expect(r.totalClicks, 0);
      expect(r.totalPurchases, 0);
      expect(r.totalEarnings, 0);
      expect(r.pendingRewards, 0);
    });

    test('ReferralUserReport.fromJson full payload', () {
      final r = ReferralUserReport.fromJson({
        'user_id': 'u1',
        'user_name': 'Gavhane',
        'user_email': 'g@x.com',
        'total_clicks': 42,
        'total_purchases': 7,
        'total_earnings': 350,
        'pending_rewards': 100,
      });
      expect(r.totalClicks, 42);
      expect(r.totalEarnings, 350);
      expect(r.pendingRewards, 100);
    });
  });

  group('DashboardStats', () {
    test('fromJson full payload', () {
      final d = DashboardStats.fromJson({
        'total_users': 10,
        'total_products': 5,
        'total_orders': 100,
        'total_revenue': 99999.5,
        'pending_orders': 3,
      });
      expect(d.totalUsers, 10);
      expect(d.totalProducts, 5);
      expect(d.totalOrders, 100);
      expect(d.totalRevenue, 99999.5);
      expect(d.pendingOrders, 3);
    });

    test('fromJson defaults to zero when missing', () {
      final d = DashboardStats.fromJson({});
      expect(d.totalUsers, 0);
      expect(d.totalRevenue, 0);
      expect(d.pendingOrders, 0);
    });
  });
}