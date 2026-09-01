import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Never pre-fill credentials — the deployed admin site is public, and a
  // prefilled form hands out working admin access to anyone who opens it.
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) return;
    final auth = context.read<AdminAuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.surface,
              AppColors.bg,
              AppColors.bg,
            ],
            center: const Alignment(0.2, -0.3),
            radius: 1.8,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.coral.withValues(alpha: 0.4), width: 1.5),
                      boxShadow: [
                        ...AppColors.shadowGlow(AppColors.coral),
                        BoxShadow(color: AppColors.coral.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('DRISTI FASHIONS',
                      textAlign: TextAlign.center,
                      style: AppColors.heading(color: AppColors.coral, size: 26, weight: FontWeight.w900, letterSpacing: 4)),
                  const SizedBox(height: 8),
                  Text('ADMIN PANEL', style: AppColors.heading(color: AppColors.gold, size: 11, letterSpacing: 8, weight: FontWeight.w700)),
                  const SizedBox(height: 56),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: AppColors.premiumCardDeco(radius: AppColors.rCardLg).copyWith(
                      boxShadow: [
                        ...AppColors.shadowLg,
                        BoxShadow(color: AppColors.coral.withValues(alpha: 0.06), blurRadius: 40, offset: const Offset(0, 10)),
                        BoxShadow(color: AppColors.coral.withValues(alpha: 0.05), blurRadius: 60, offset: const Offset(0, 0)),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailCtrl,
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'EMAIL',
                            labelStyle: AppColors.heading(color: AppColors.textMuted, size: 10, letterSpacing: 2.5, weight: FontWeight.w700),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.coral.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.email_outlined, color: AppColors.coral, size: 18),
                            ),
                            filled: true,
                            fillColor: AppColors.bgAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.coral, width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'PASSWORD',
                            labelStyle: AppColors.heading(color: AppColors.textMuted, size: 10, letterSpacing: 2.5, weight: FontWeight.w700),
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.coral.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.lock_outlined, color: AppColors.coral, size: 18),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 18),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                            filled: true,
                            fillColor: AppColors.bgAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.coral, width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Consumer<AdminAuthProvider>(builder: (_, a, __) =>
                            a.error != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(children: [
                                      Container(
                                        width: 24, height: 24,
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.error_outline, color: AppColors.error, size: 14),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(a.error!, style: TextStyle(color: AppColors.error, fontSize: 11))),
                                    ]),
                                  )
                                : const SizedBox.shrink()),
                        const SizedBox(height: 26),
                        Consumer<AdminAuthProvider>(builder: (_, a, __) =>
                            FashionButton(
                              label: 'Sign In',
                              icon: Icons.login_rounded,
                              loading: a.isLoading,
                              onPressed: a.isLoading ? null : _login,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 28, height: 1, decoration: AppColors.goldHairline),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.verified_user_outlined, color: AppColors.coral.withValues(alpha: 0.8), size: 13),
                      ),
                      Text('SECURED ADMIN ACCESS',
                          style: AppColors.heading(color: AppColors.textMuted, size: 8.5, letterSpacing: 3, weight: FontWeight.w700)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(width: 4, height: 4, decoration: BoxDecoration(color: AppColors.coral.withValues(alpha: 0.6), shape: BoxShape.circle)),
                      ),
                      Container(width: 28, height: 1, decoration: AppColors.goldHairline),
                    ],
                  ),
                ],
              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
