import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/image_upload_service.dart';

class BrandHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onMenuTap;

  const BrandHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onMenuTap,
  });

  Widget _iconBox(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surfaceRaised, AppColors.surfaceAlt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.borderLight, width: 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: AppColors.shadowSm,
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Leading affordance: the hamburger opens the drawer on compact layouts
    // only — the desktop shell shows a permanent sidebar, so no menu button.
    // Headers without a menu callback are pushed detail/form pages; they get
    // a back arrow (previously they showed a dead menu icon and no way back).
    Widget? leading;
    if (onMenuTap != null) {
      if (!Responsive.isDesktop(context)) leading = _iconBox(Icons.menu, onMenuTap!);
    } else if (Navigator.of(context).canPop()) {
      leading = _iconBox(Icons.arrow_back, () => Navigator.of(context).maybePop());
    }
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 0, right: 0, bottom: 0,
      ),
      decoration: AppColors.headerDeco,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Solid ink title (design system: flat, readable type;
                      // gold hairline below carries the luxury accent). The
                      // FittedBox keeps long titles on one line on phones.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title.toUpperCase(),
                          style: AppColors.heading(
                            color: AppColors.textPrimary,
                            size: 24,
                            weight: FontWeight.w800,
                            letterSpacing: 3,
                            height: 1,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(width: 16, height: 2, decoration: BoxDecoration(
                              gradient: LinearGradient(colors: AppColors.coralGradient),
                              borderRadius: BorderRadius.circular(1),
                            )),
                            const SizedBox(width: 8),
                            Text(
                              subtitle!,
                                  style: AppColors.heading(
                                color: AppColors.textMuted,
                                size: 10,
                                letterSpacing: 3,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
          ),
          Container(
            height: 2,
            decoration: const BoxDecoration(gradient: AppColors.rainbowAccent),
          ),
        ],
      ),
    );
  }
}

class FashionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? height;
  final Color? accentColor;

  const FashionCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.height,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color ?? AppColors.surface,
            AppColors.surfaceAlt,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: AppColors.shadowMd,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.03),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (accentColor != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 32, height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor!, accentColor!.withValues(alpha: 0.3)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.surfaceAlt],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: AppColors.shadowSm,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white.withValues(alpha: 0.03), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              value,
                              style: AppColors.heading(
                                color: accent,
                                size: 26,
                                weight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              label.toUpperCase(),
                                  style: AppColors.heading(
                                color: AppColors.textMuted,
                                size: 10,
                                letterSpacing: 2.5,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: accent.withValues(alpha: 0.2), width: 1),
                          ),
                          child: Icon(Icons.arrow_forward_ios, color: accent.withValues(alpha: 0.5), size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;

  const Tag({
    super.key,
    required this.text,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.14) : color.withValues(alpha: 0.04),
        border: Border.all(
          color: color.withValues(alpha: filled ? 0.35 : 0.4),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: filled ? [
          BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 1)),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppColors.heading(
                color: color,
                size: 9,
                weight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionGrid extends StatelessWidget {
  final List<ActionItem> items;

  const ActionGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 12.0;
          // Base tile sizing on the ACTUAL available width, not the device
          // width — correct inside the capped desktop shell.
          final cols = Responsive.compactColumns(constraints.maxWidth);
          final tileW = (constraints.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap, runSpacing: gap,
            children: items.map((item) {
              return GestureDetector(
                onTap: item.onTap,
                child: Container(
                  width: tileW,
                  decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.surface, AppColors.surfaceAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.btnBorder, width: 1),
                boxShadow: AppColors.shadowSm,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.white.withValues(alpha: 0.03), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: AppColors.premiumGoldDeco(radius: 10),
                      child: Icon(item.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      item.label.toUpperCase(),
                      style: AppColors.heading(
                      color: AppColors.textSecondary,
                      size: 11,
                      weight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                    ),
                  ],
                ),
              ),
            ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final List<Color>? gradient;
  final VoidCallback onTap;
  ActionItem({required this.label, required this.icon, required this.color, this.gradient, required this.onTap});
}

class FashionNavDrawer extends StatelessWidget {
  final String currentRoute;

  const FashionNavDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bg,
      width: 300,
      child: AdminNavPanel(currentRoute: currentRoute, inDrawer: true),
    );
  }
}

/// Route-level scaffold. Compact layouts keep the hamburger + drawer; desktop
/// (>= Responsive.tablet) shows a permanent sidebar so navigation is always
/// visible — standard admin-panel ergonomics for the website.
class AdminScaffold extends StatelessWidget {
  final String currentRoute;
  final Widget body;
  final Widget? floatingActionButton;

  const AdminScaffold({
    super.key,
    required this.currentRoute,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    if (!Responsive.isDesktop(context)) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        drawer: FashionNavDrawer(currentRoute: currentRoute),
        floatingActionButton: floatingActionButton,
        body: body,
      );
    }
    return Scaffold(
      backgroundColor: AppColors.bg,
      floatingActionButton: floatingActionButton,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 280,
            child: AdminNavPanel(currentRoute: currentRoute, inDrawer: false),
          ),
          Container(width: 1, color: AppColors.borderLight),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Shared navigation panel — rendered inside the mobile Drawer and as the
/// persistent desktop sidebar.
class AdminNavPanel extends StatelessWidget {
  final String currentRoute;
  final bool inDrawer;

  const AdminNavPanel({super.key, required this.currentRoute, required this.inDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.navGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 40,
                left: 24, right: 24, bottom: 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.surface, AppColors.surfaceAlt],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight, width: 1),
                ),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.coral.withValues(alpha: 0.4), width: 1.2),
                      boxShadow: AppColors.shadowGlow(AppColors.coral),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('DRISTI FASHIONS', style: AppColors.heading(color: AppColors.textPrimary, size: 17, weight: FontWeight.w900, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 20, height: 2, decoration: BoxDecoration(
                        gradient: LinearGradient(colors: AppColors.goldGradient),
                        borderRadius: BorderRadius.circular(1),
                      )),
                      const SizedBox(width: 8),
                      Text('ADMIN PANEL', style: AppColors.heading(color: AppColors.gold, size: 9, letterSpacing: 4, weight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _navItem(Icons.dashboard, 'Dashboard', '/dashboard', context),
                  _navItem(Icons.people, 'Users', '/users', context),
                  _navItem(Icons.inventory_2, 'Products', '/products', context),
                  _navItem(Icons.receipt_long, 'Orders', '/orders', context),
                  _navItem(Icons.category, 'Categories', '/categories', context),
                  _navItem(Icons.view_carousel, 'Banners', '/banners', context),
                  _navItem(Icons.card_giftcard, 'Coupons', '/coupons', context),
                  _navItem(Icons.account_balance_wallet, 'Payment Methods', '/payment-methods', context),
                  _navItem(Icons.local_shipping, 'Delivery', '/delivery-settings', context),
                  _navItem(Icons.share_outlined, 'Referrals', '/referrals', context),
                  _navItem(Icons.mail_outline, 'Messages', '/messages', context),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
              ),
              child: Consumer<ThemeProvider>(
                builder: (_, tp, __) {
                  final dark = tp.isDark;
                  return GestureDetector(
                    onTap: () => tp.toggle(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: dark
                          ? AppColors.premiumGoldDeco(radius: 10)
                          : BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.purple40, AppColors.surfaceAlt],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: AppColors.btnBorder, width: 1),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: AppColors.shadowSm,
                            ),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: (dark ? Colors.white : AppColors.coralDark).withValues(alpha: dark ? 0.20 : 0.16),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              dark ? Icons.dark_mode : Icons.light_mode,
                              color: dark ? Colors.white : AppColors.coralDark,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            dark ? 'DARK MODE' : 'LIGHT MODE',
                            style: AppColors.heading(
                              color: dark ? Colors.white : AppColors.coralDark,
                              size: 11,
                              weight: FontWeight.w800,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GestureDetector(
                onTap: () => _logout(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: AppColors.premiumGoldDeco(radius: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.logout, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text('SIGN OUT', style: AppColors.heading(color: Colors.white, size: 11, weight: FontWeight.w800, letterSpacing: 2.5)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.logout, color: AppColors.error, size: 16),
            ),
            const SizedBox(width: 12),
            Text('Sign Out', style: AppColors.heading(color: AppColors.textPrimary, size: 16, weight: FontWeight.w700)),
          ],
        ),
        content: Text('Are you sure you want to sign out?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.surface, AppColors.surfaceAlt], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  border: Border.all(color: AppColors.borderLight, width: 1),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: AppColors.shadowSm,
                ),
                child: Text('CANCEL', style: AppColors.heading(color: AppColors.textSecondary, letterSpacing: 1, size: 10, weight: FontWeight.w700)),
              ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              final api = ApiService();
              await api.clearTokens();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: AppColors.premiumGoldDeco(radius: 7),
              child: Text('SIGN OUT', style: AppColors.heading(color: Colors.white, letterSpacing: 1.5, size: 10, weight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, String route, BuildContext ctx) {
    final active = currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            // Only the drawer overlay needs dismissing; the desktop sidebar
            // stays in place across navigation.
            if (inDrawer) Navigator.pop(ctx);
            if (route != currentRoute) Navigator.pushReplacementNamed(ctx, route);
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
            decoration: BoxDecoration(
              // Lexron signature: the active item is a filled violet gradient
              // pill with white content; inactive items are transparent.
              gradient: active
                  ? const LinearGradient(
                      colors: AppColors.navActiveGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: active ? AppColors.shadowGlow(AppColors.coral) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: active ? Colors.white.withValues(alpha: 0.22) : AppColors.bgAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: active ? Colors.white.withValues(alpha: 0.30) : AppColors.borderLight, width: 1),
                  ),
                  child: Icon(icon, color: active ? Colors.white : AppColors.textMuted, size: 17),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppColors.heading(
                    color: active ? Colors.white : AppColors.textSecondary,
                    size: 13,
                    weight: active ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyBox extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyBox({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surfaceAlt],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppColors.rCard),
            border: Border.all(color: AppColors.borderLight, width: 1),
            boxShadow: AppColors.shadowSm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.coral.withValues(alpha: 0.12), AppColors.coral.withValues(alpha: 0.04)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.coral.withValues(alpha: 0.25), width: 1),
                ),
                child: Icon(icon, color: AppColors.coral, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                message.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppColors.heading(color: AppColors.textSecondary, size: 11.5, letterSpacing: 2.5, weight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Container(width: 40, height: 2, decoration: AppColors.goldHairline),
            ],
          ),
        ),
      ),
    );
  }
}

/// Branded loading indicator — a gold ring over a soft royal-blue halo with an
/// optional caption. Reads as intentional and premium versus a bare spinner.
class BrandLoader extends StatelessWidget {
  final String? label;
  const BrandLoader({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [AppColors.coral.withValues(alpha: 0.14), Colors.transparent],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation(AppColors.coral),
                backgroundColor: AppColors.coral.withValues(alpha: 0.12),
              ),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(
              label!.toUpperCase(),
              style: AppColors.heading(color: AppColors.textMuted, size: 10, letterSpacing: 3, weight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.border.withValues(alpha: 0.3),
            AppColors.borderLight,
            AppColors.border.withValues(alpha: 0.3),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String title;

  const SectionLabel({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Row(
        children: [
          Container(
            width: 24, height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColors.coralGradient),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: AppColors.heading(
              color: AppColors.textSecondary,
              size: 11,
              letterSpacing: 1.5,
              weight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            height: 1,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.borderLight, AppColors.border.withValues(alpha: 0.3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchInput extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchInput({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 2),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.search, color: AppColors.coral, size: 16),
          ),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderLight, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.coral, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

enum ButtonVariant { primary }

extension ButtonVariantColors on ButtonVariant {
  List<Color> get gradient {
    switch (this) {
      case ButtonVariant.primary: return [AppColors.btnColor, AppColors.btnColor80];
    }
  }
  Color get base {
    switch (this) {
      case ButtonVariant.primary: return AppColors.btnColor;
    }
  }
}

/// A flat solid-violet action button (Dristi Fashions). When [color] is supplied
/// the button renders in that tone, otherwise it uses the primary violet surface.
/// Text/icons sit in white for contrast against the fill.
class FashionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final ButtonVariant variant;
  final Color? color;
  final IconData? icon;

  const FashionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = ButtonVariant.primary,
    this.color,
    this.icon,
  });

  @override
  State<FashionButton> createState() => _FashionButtonState();
}

class _FashionButtonState extends State<FashionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final custom = widget.color;
    const onColor = Colors.white;

    final BoxDecoration deco = custom == null
        ? AppColors.premiumGoldDeco(radius: 12)
        : BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.lerp(custom, Colors.white, 0.22)!, custom, Color.lerp(custom, Colors.black, 0.18)!],
              stops: const [0.0, 0.55, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color.lerp(custom, Colors.black, 0.25)!, width: 1),
            boxShadow: AppColors.shadowGlow(custom),
          );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.55,
          duration: const Duration(milliseconds: 150),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: Stack(
              children: [
                // Metallic plate
                Positioned.fill(child: DecoratedBox(decoration: deco)),
                // Top sheen — light catching the metal edge
                Positioned(
                  top: 1, left: 1, right: 1,
                  height: 24,
                  child: DecoratedBox(decoration: AppColors.goldSheen(radius: 11)),
                ),
                // Label / spinner
                Center(
                  child: widget.loading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: onColor))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(widget.icon, size: 17, color: onColor),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              widget.label.toUpperCase(),
                              style: AppColors.heading(size: 12.5, weight: FontWeight.w800, letterSpacing: 3.5, color: onColor),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoBlock({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(label.toUpperCase(),
              style: AppColors.heading(
                color: AppColors.textMuted,
                size: 9,
                letterSpacing: 2,
                weight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgAlt,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(value,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Row(
            children: [
              Container(
                width: 20, height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.coralGradient),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(title.toUpperCase(),
                style: AppColors.heading(
                  color: AppColors.textSecondary,
                  size: 11,
                  letterSpacing: 1.5,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.surface, AppColors.surfaceAlt],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppColors.borderLight, width: 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppColors.shadowMd,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class StyledInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool number;
  final int? maxLines;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  /// Lets a caller react as the value is typed (e.g. a live total preview).
  final void Function(String)? onChanged;

  const StyledInput({
    super.key,
    required this.controller,
    required this.label,
    this.number = false,
    this.maxLines,
    this.hint,
    this.icon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines ?? 1,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        validator: validator,
        onChanged: onChanged,
        cursorColor: AppColors.coral,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
          floatingLabelStyle: TextStyle(color: AppColors.coral, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700),
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
          prefixIcon: icon == null ? null : Container(
            margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: AppColors.coral, size: 16),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          filled: true,
          fillColor: AppColors.bgAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.coral, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.error, width: 1.6),
          ),
          errorStyle: TextStyle(color: AppColors.error, fontSize: 10.5, fontWeight: FontWeight.w600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

class StyledDropdown extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String label;

  const StyledDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        dropdownColor: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.coral, size: 22),
        style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textMuted, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600),
          floatingLabelStyle: TextStyle(color: AppColors.coral, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.w700),
          filled: true,
          fillColor: AppColors.bgAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.coral, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

class ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: value ? AppColors.coral.withValues(alpha: 0.08) : AppColors.bgAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: value ? AppColors.coral.withValues(alpha: 0.35) : AppColors.border, width: 1),
        boxShadow: value ? [BoxShadow(color: AppColors.coral.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 28, width: 48,
            child: Switch(
        value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.coral.withValues(alpha: 0.5),
              inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.2),
              activeThumbColor: AppColors.coral,
            ),
          ),
          const SizedBox(width: 8),
          Text(label.toUpperCase(),
            style: AppColors.heading(
              color: value ? AppColors.coral : AppColors.textMuted,
              size: 9,
              letterSpacing: 1.5,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared list-row card shell — the white surface, hairline border, 16px radius
/// and soft shadow used by every list screen (products, orders, categories,
/// coupons, banners, users). Replaces the copy-pasted double-nested Container.
class ListCardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;

  const ListCardShell({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderLight, width: 1),
        borderRadius: BorderRadius.circular(AppColors.rCard),
        boxShadow: AppColors.shadowMd,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppColors.rCard),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

/// Shared confirm-delete dialog — the tokenized replacement for the inline
/// AlertDialog duplicated across products / categories / coupons / banners.
/// Returns true when the user confirms.
Future<bool> confirmDeleteDialog(
  BuildContext context, {
  required String message,
  String title = 'DELETE',
  String confirmLabel = 'DELETE',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.rButton)),
      title: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.delete_outlined, color: AppColors.error, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppColors.heading(color: AppColors.error, letterSpacing: 3, size: 14, weight: FontWeight.w800)),
      ]),
      content: Text(message, style: TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.borderLight, width: 1),
              borderRadius: BorderRadius.circular(AppColors.rInput),
            ),
            child: Text('CANCEL', style: AppColors.heading(color: AppColors.textSecondary, letterSpacing: 2, size: 10, weight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppColors.rInput),
            ),
            child: Text(confirmLabel, style: AppColors.heading(color: Colors.white, letterSpacing: 2, size: 10, weight: FontWeight.w800)),
          ),
        ),
      ],
    ),
  );
  return ok == true;
}

/// Upload guidelines for an image field. Shown next to every image picker so
/// the admin sees the rules before hitting a validation error.
class ImageSpecsBox extends StatelessWidget {
  final ImageSpecs specs;

  const ImageSpecsBox({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            Icon(icon, size: 15, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: AppColors.textMuted))),
          ]),
        );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.coral.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.coral.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Image requirements',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        row(Icons.aspect_ratio,
            'Recommended: ${specs.recWidth} × ${specs.recHeight} px (${specs.ratioLabel})'),
        row(Icons.photo_size_select_large, 'Minimum: $kImageMinWidth × $kImageMinHeight px'),
        row(Icons.sd_storage_outlined, 'Max file size: 5 MB'),
        row(Icons.image_outlined, 'Formats: JPG, PNG, WebP'),
      ]),
    );
  }
}

/// The "Upload Image" button used by every image field, with a busy state.
class ImageUploadButton extends StatelessWidget {
  final bool uploading;
  final VoidCallback? onPressed;
  final String label;

  const ImageUploadButton({
    super.key,
    required this.uploading,
    required this.onPressed,
    this.label = 'Upload Image',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: uploading ? null : onPressed,
        icon: uploading
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.coral))
            : const Icon(Icons.upload_file, size: 18),
        label: Text(uploading ? 'Uploading…' : label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.coral,
          side: const BorderSide(color: AppColors.coral),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
