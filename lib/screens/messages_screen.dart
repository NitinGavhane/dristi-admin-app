import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/theme.dart';
import '../models/contact.dart';
import '../services/api_service.dart';
import '../services/admin_service.dart';
import '../widgets.dart';

/// Website enquiries and newsletter signups.
///
/// The Contact form and subscribe box used to show a thank-you and throw the
/// data away. Both now land here — the store's domain has no mailbox, so this
/// screen is the delivery route.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final AdminService _admin = AdminService(ApiService());

  List<ContactMessage> _messages = [];
  List<NewsletterSubscriber> _subscribers = [];
  bool _loading = true;
  bool _showSubscribers = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final messages = await _admin.getContactMessages();
      final subscribers = await _admin.getNewsletterSubscribers();
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _subscribers = subscribers;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _toast('Could not load messages: $e', error: true);
    }
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.error : null,
    ));
  }

  int get _unreadCount => _messages.where((m) => !m.isRead).length;

  static String _when(DateTime? d) {
    if (d == null) return '';
    final local = d.toLocal();
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year}  ${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _openMessage(ContactMessage m) async {
    if (!m.isRead) {
      try {
        await _admin.markContactMessageRead(m.id);
        _load();
      } catch (_) {/* reading is best-effort; the dialog still opens */}
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(m.subject?.isNotEmpty == true ? m.subject! : 'Enquiry',
            style: TextStyle(
                color: AppColors.coral,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('From', m.fullName),
              _row('Email', m.email),
              _row('Received', _when(m.createdAt)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(m.message,
                    style: TextStyle(
                        color: AppColors.textPrimary, fontSize: 13, height: 1.55)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: m.email));
              _toast('Email address copied');
            },
            icon: Icon(Icons.copy, size: 15, color: AppColors.textMuted),
            label: Text('COPY EMAIL',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: AppColors.premiumGoldDeco(radius: 6),
              child: const Text('CLOSE',
                  style: TextStyle(
                      color: Colors.white, letterSpacing: 2, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 74,
              child: Text(label,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),
            Expanded(
              child: Text(value,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Future<void> _delete(ContactMessage m) async {
    final ok = await confirmDeleteDialog(context,
        message: 'Delete the enquiry from ${m.fullName}?');
    if (!ok) return;
    try {
      await _admin.deleteContactMessage(m.id);
      _toast('Enquiry deleted');
      _load();
    } catch (e) {
      _toast('Delete failed: $e', error: true);
    }
  }

  void _copyAllSubscribers() {
    if (_subscribers.isEmpty) return;
    Clipboard.setData(
        ClipboardData(text: _subscribers.map((s) => s.email).join(', ')));
    _toast('${_subscribers.length} email addresses copied');
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      currentRoute: '/messages',
      floatingActionButton: _showSubscribers && _subscribers.isNotEmpty
          ? Container(
              width: 52,
              height: 52,
              decoration: AppColors.premiumGoldDeco(radius: 14),
              child: IconButton(
                tooltip: 'Copy all email addresses',
                icon: const Icon(Icons.copy_all, color: Colors.white),
                onPressed: _copyAllSubscribers,
              ),
            )
          : null,
      body: Column(children: [
        Builder(
          builder: (ctx) => BrandHeader(
            title: 'Messages',
            subtitle: _unreadCount > 0
                ? '$_unreadCount UNREAD · ${_subscribers.length} SUBSCRIBERS'
                : '${_messages.length} ENQUIRIES · ${_subscribers.length} SUBSCRIBERS',
            onMenuTap: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        Expanded(
          child: _loading
              ? const BrandLoader(label: 'Loading')
              : RefreshIndicator(
                  color: AppColors.coral,
                  backgroundColor: AppColors.surface,
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      _tabs(),
                      const SizedBox(height: 12),
                      if (_showSubscribers)
                        ..._buildSubscribers()
                      else
                        ..._buildMessages(),
                    ],
                  ),
                ),
        ),
      ]),
    );
  }

  Widget _tabs() {
    Widget tab(String label, bool selected, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient:
                    selected ? LinearGradient(colors: AppColors.coralGradient) : null,
                color: selected ? null : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: selected ? AppColors.coral : AppColors.border, width: 1),
              ),
              child: Text(label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
        );

    return Row(children: [
      tab('ENQUIRIES', !_showSubscribers,
          () => setState(() => _showSubscribers = false)),
      const SizedBox(width: 8),
      tab('SUBSCRIBERS', _showSubscribers,
          () => setState(() => _showSubscribers = true)),
    ]);
  }

  List<Widget> _buildMessages() {
    if (_messages.isEmpty) {
      return [
        const SizedBox(height: 40),
        const EmptyBox(
            icon: Icons.mark_email_read_outlined,
            message: 'No enquiries from the website yet'),
      ];
    }
    return _messages.map((m) {
      return ListCardShell(
        child: InkWell(
          onTap: () => _openMessage(m),
          child: Row(children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 12, top: 4),
              decoration: BoxDecoration(
                color: m.isRead ? Colors.transparent : AppColors.coral,
                shape: BoxShape.circle,
                border: m.isRead
                    ? Border.all(color: AppColors.borderLight, width: 1)
                    : null,
              ),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.fullName,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: m.isRead ? FontWeight.w600 : FontWeight.w800,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  m.subject?.isNotEmpty == true ? m.subject! : m.message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text('${m.email} · ${_when(m.createdAt)}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ]),
            ),
            GestureDetector(
              onTap: () => _delete(m),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.error, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.delete_outline, color: AppColors.error, size: 15),
              ),
            ),
          ]),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSubscribers() {
    if (_subscribers.isEmpty) {
      return [
        const SizedBox(height: 40),
        const EmptyBox(
            icon: Icons.alternate_email, message: 'No newsletter signups yet'),
      ];
    }
    return _subscribers
        .map((s) => ListCardShell(
              child: Row(children: [
                Icon(Icons.alternate_email, size: 17, color: AppColors.coral),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.email,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                Text(_when(s.createdAt),
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ]),
            ))
        .toList();
  }
}
