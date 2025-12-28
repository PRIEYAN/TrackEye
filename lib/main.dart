import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/shipment_provider.dart';
import 'providers/auth_provider.dart';
import 'models/auth_models.dart';
import 'views/auth/splash_screen.dart';
import 'views/supplier/dashboard_view.dart';
import 'views/forwarder/forwarder_dashboard.dart';
import 'views/buyer/buyer_dashboard.dart';
import 'core/constants.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShipmentProvider()),
      ],
      child: const TrackEyeApp(),
    ),
  );
}

class TrackEyeApp extends StatelessWidget {
  const TrackEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackEye AI',
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.accentColor,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/dashboard': (context) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final role = authProvider.userRole;
          if (role == null) {
            return const SplashScreen();
          }
          switch (role) {
            case UserRole.supplier:
              return const SupplierDashboardView();
            case UserRole.forwarder:
              return const ForwarderDashboard();
            case UserRole.buyer:
              return const BuyerDashboard();
          }
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
