import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final AdminService _admin = AdminService(ApiService());
  AdminOrder? _order;
  bool _loading = true;

  @override
  void didChangeDependencies() { super.didChangeDependencies(); if (_order == null) _load(); }

  Future<void> _load() async {
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id == null) return;
    try { final orders = await _admin.getOrders(); final o = orders.cast<AdminOrder?>().firstWhere((x) => x?.id == id, orElse: () => null); if (mounted) setState(() { _order = o; _loading = false; }); } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _upd(String s) async { if (_order == null) return; try { await _admin.updateOrderStatus(_order!.id, s); _load(); } catch (_) {} }

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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _loading
        ? const BrandLoader(label: 'Loading')
        : _order == null
          ? const EmptyBox(icon: Icons.search_off, message: 'Not found')
          : Column(children: [
              BrandHeader(title: 'Order', subtitle: '#${_order!.orderNumber}'),
              Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
                FashionCard(accentColor: _sc(_order!.orderStatus), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text('#${_order!.orderNumber}', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Tag(text: _sd(_order!.orderStatus), color: _sc(_order!.orderStatus)),
                  ]),
                  const DividerLine(),
                  InfoBlock(label: 'Payment', value: _order!.paymentStatus.toUpperCase()),
                  InfoBlock(label: 'Subtotal', value: '?${_order!.subtotal.toStringAsFixed(2)}'),
                  InfoBlock(label: 'GST', value: '?${_order!.gstAmount.toStringAsFixed(2)}'),
                  if (_order!.discountAmount > 0) InfoBlock(label: 'Discount', value: '-\$${_order!.discountAmount.toStringAsFixed(2)}', valueColor: AppColors.success),
                  const DividerLine(),
                  InfoBlock(label: 'Total', value: '?${_order!.finalAmount.toStringAsFixed(2)}', valueColor: AppColors.coral),
                  if (_order!.shippingAddress != null) InfoBlock(label: 'Address', value: _order!.shippingAddress!),
                ])),
                const SizedBox(height: 24),
                const SectionLabel(title: 'Items'),
                const SizedBox(height: 8),
                ...(_order!.items.map((item) {
                  return ListCardShell(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.bgAlt, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.shopping_bag_outlined, color: AppColors.textMuted, size: 20)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.productName, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text('Qty: ${item.quantity}', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.coral.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.coral.withValues(alpha: 0.2)),
                          ),
                          child: Text('?${(item.price * item.quantity).toStringAsFixed(2)}', style: TextStyle(color: AppColors.coral, fontWeight: FontWeight.w800, fontSize: 13)),
                        ),
                      ]),
                  );
                })),
                const SizedBox(height: 28),
                const SectionLabel(title: 'Update Status'),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: orderStatuses.map((s) {
                  final curr = s == _order!.orderStatus;
                  return GestureDetector(
                    onTap: curr ? null : () => _upd(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: curr
                          ? AppColors.premiumGoldDeco(radius: 8)
                          : BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.btnColor40, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
                              border: Border.all(color: AppColors.btnBorder, width: 1),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: AppColors.shadowSm,
                            ),
                      child: Text(_sd(s), style: TextStyle(
                        color: curr ? Colors.white : AppColors.btnColor,
                        fontSize: 10,
                        fontWeight: curr ? FontWeight.w800 : FontWeight.w700,
                        letterSpacing: 1.5,
                      )),
                    ),
                  );
                }).toList()),
                const SizedBox(height: 48),
              ]))),
            ]),
    );
  }
}
