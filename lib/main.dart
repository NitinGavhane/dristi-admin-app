import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/admin_service.dart';

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();

    final apiService = ApiService();
    final adminService = AdminService(apiService);
    final authProvider = AdminAuthProvider(adminService, apiService);

    apiService.onUnauthorized = () {
      authProvider.logout();
    };

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          Provider.value(value: adminService),
        ],
        child: const AdminApp(),
      ),
    );
  }, (error, stack) {
    debugPrint('[FATAL] $error\n$stack');
  });
}
