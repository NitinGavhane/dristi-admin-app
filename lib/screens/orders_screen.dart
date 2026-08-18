import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final AdminService _admin = AdminService(ApiService());
  List<AdminOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { final o = await _admin.getOrders(); if (mounted) setState(() { _orders = o; _loading = false; }); } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Color _sc(String s) {
    switch (s) {
      case 'pending_payment': return AppColors.warning;
      case 'placed': return AppColors.info;
      case 'processing': return AppColors.warning;
      case 'dispatched': return AppColors.purple;
      case 'out_for_delivery': return AppColors.teal;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.textMuted;
    }
  }

  String _sd(String s) {
    switch (s) {
      case 'pending_payment': return 'AWAITING PAYMENT';
      case 'placed': return 'PLACED';
      case 'processing': return 'PROCESSING';
      case 'dispatched': return 'DISPATCHED';
      case 'out_for_delivery': return 'OUT FOR DELIVERY';
      case 'delivered': return 'DELIVERED';
      case 'cancelled': return 'CANCELLED';
      default: return s.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/orders',
      body: Column(children: [
        Builder(builder: (ctx) => BrandHeader(title: 'Orders', subtitle: '${_orders.length} TOTAL', onMenuTap: () => Scaffold.of(ctx).openDrawer())),
        Expanded(child: _loading
          ? const BrandLoader(label: 'Loading')
          : _orders.isEmpty
            ? const EmptyBox(icon: Icons.receipt_long_outlined, message: 'No orders')
            : RefreshIndicator(color: AppColors.coral, backgroundColor: AppColors.surface, onRefresh: _load, child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                itemCount: _orders.length,
                itemBuilder: (_, i) {
                  final o = _orders[i];
                  final sc = _sc(o.orderStatus);
                  return ListCardShell(
                    onTap: () => Navigator.pushNamed(context, '/order-detail', arguments: o.id),
                      child: Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: sc.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: sc.withValues(alpha: 0.2), width: 1),
                            ),
                            child: Icon(Icons.receipt_outlined, color: sc, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text('#${o.orderNumber}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.5), overflow: TextOverflow.ellipsis)),
                            ]),
                            const SizedBox(height: 4),
                            Text('₹${o.finalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.coral, fontWeight: FontWeight.w900, fontSize: 16)),
                            const SizedBox(height: 8),
                            Wrap(spacing: 4, children: [
                              Tag(text: _sd(o.orderStatus), color: sc),
                              Tag(text: o.paymentStatus.toUpperCase(), color: o.paymentStatus == 'paid' ? AppColors.success : o.paymentStatus == 'refunded' ? AppColors.info : AppColors.warning),
                            ]),
                          ])),
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: sc.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: sc.withValues(alpha: 0.15), width: 1),
                            ),
                            child: Icon(Icons.chevron_right, color: sc.withValues(alpha: 0.5), size: 18),
                          ),
                        ]),
                  );
                },
              )),
        ),
      ]),
    );
  }
}
