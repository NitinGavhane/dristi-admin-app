import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/users_screen.dart';
import 'screens/products_screen.dart';
import 'screens/product_form_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/order_detail_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/coupons_screen.dart';
import 'screens/coupon_form_screen.dart';
import 'screens/banners_screen.dart';
import 'screens/banner_form_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/payment_method_form_screen.dart';
import 'screens/delivery_settings_screen.dart';
import 'screens/referrals_screen.dart';
import 'screens/messages_screen.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, theme, __) {
        final isDark = theme.isDark;
        return MaterialApp(
          title: 'Admin Panel',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.bg,
            // Inter is the design-system body typeface (Dristi Fashions); explicit
            // TextStyles without a fontFamily inherit it via DefaultTextStyle.
            // Headings/labels opt into Montserrat via AppColors.heading(...).
            textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
            colorScheme: ColorScheme.light(
              primary: AppColors.coral,
              secondary: AppColors.gold,
              surface: AppColors.surface,
              error: AppColors.error,
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: AppColors.surfaceAlt,
              behavior: SnackBarBehavior.floating,
              elevation: 8,
              actionTextColor: AppColors.coral,
              contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColors.coral.withValues(alpha: 0.25), width: 1),
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.coral,
              selectionColor: AppColors.coral.withValues(alpha: 0.22),
              selectionHandleColor: AppColors.coral,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.coral),
            iconTheme: IconThemeData(color: AppColors.textSecondary),
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.coral.withValues(alpha: 0.25), width: 1),
              ),
              textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            dividerTheme: DividerThemeData(color: AppColors.borderLight, thickness: 1),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surface,
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.coral.withValues(alpha: 0.22), width: 1),
              ),
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: const FadeUpwardsPageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.bg,
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            colorScheme: ColorScheme.dark(
              primary: AppColors.coral,
              secondary: AppColors.gold,
              surface: AppColors.surface,
              error: AppColors.error,
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: AppColors.surfaceAlt,
              behavior: SnackBarBehavior.floating,
              elevation: 8,
              actionTextColor: AppColors.coral,
              contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: AppColors.coral.withValues(alpha: 0.25), width: 1),
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.coral,
              selectionColor: AppColors.coral.withValues(alpha: 0.22),
              selectionHandleColor: AppColors.coral,
            ),
            progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.coral),
            iconTheme: IconThemeData(color: AppColors.textSecondary),
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.coral.withValues(alpha: 0.25), width: 1),
              ),
              textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            dividerTheme: DividerThemeData(color: AppColors.borderLight, thickness: 1),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surface,
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.coral.withValues(alpha: 0.22), width: 1),
              ),
            ),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: const FadeUpwardsPageTransitionsBuilder(),
              },
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          // Responsive: on wide screens (tablet/desktop) the whole app is
          // centered and capped so content never stretches awkwardly; on phones
          // it fills the screen. The side gutters use a soft themed gradient.
          builder: (context, child) {
            final w = MediaQuery.of(context).size.width;
            if (w <= Responsive.maxContentWidth || child == null) {
              return child ?? const SizedBox.shrink();
            }
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.bgGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Container(
                  width: Responsive.maxContentWidth,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 40,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: child,
                ),
              ),
            );
          },
          home: const _SplashGate(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/dashboard': (_) => const DashboardScreen(),
            '/users': (_) => const UsersScreen(),
            '/products': (_) => const ProductsScreen(),
            '/product-form': (_) => const ProductFormScreen(),
            '/orders': (_) => const OrdersScreen(),
            '/order-detail': (_) => const OrderDetailScreen(),
            '/categories': (_) => const CategoriesScreen(),
            '/category-form': (_) => const CategoryFormScreen(),
            '/coupons': (_) => const CouponsScreen(),
            '/coupon-form': (_) => const CouponFormScreen(),
            '/banners': (_) => const BannersScreen(),
            '/banner-form': (_) => const BannerFormScreen(),
            '/payment-methods': (_) => const PaymentMethodsScreen(),
            '/payment-method-form': (_) => const PaymentMethodFormScreen(),
            '/delivery-settings': (_) => const DeliverySettingsScreen(),
            '/referrals': (_) => const ReferralsScreen(),
            '/messages': (_) => const MessagesScreen(),
          },
        );
      },
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    final auth = context.read<AdminAuthProvider>();
    await Future.wait([
      auth.checkAuth(),
      Future.delayed(const Duration(milliseconds: 400)),
    ]);
    if (mounted) {
      await _ctrl.reverse();
      setState(() => _started = true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_started) {
      final auth = context.watch<AdminAuthProvider>();
      Widget dest = const LoginScreen();
      if (auth.isAuthenticated) {
        dest = const DashboardScreen();
      }
      return dest;
    }
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.coral.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: AppColors.shadowGlow(AppColors.coral),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
                Text('DRISTI FASHIONS', style: AppColors.heading(color: AppColors.coral, size: 28, weight: FontWeight.w900, letterSpacing: 4)),
                const SizedBox(height: 8),
                Text('ADMIN PANEL', style: AppColors.heading(color: AppColors.gold, size: 11, letterSpacing: 8, weight: FontWeight.w700)),
                const SizedBox(height: 48),
                SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.coral.withValues(alpha: 0.6),
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
