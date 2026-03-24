import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/index.dart';
import 'features/auth/login_screen.dart';
import 'features/common/providers/risk_alerts_provider.dart';
import 'features/common/risk_alerts_screen.dart';
import 'features/common/success_screen.dart';
import 'features/home/home_screen.dart';
import 'features/transfer/transfer_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RiskAlertsProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bank UI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            surface: AppColors.whiteColor,
          ),
          scaffoldBackgroundColor: AppColors.backgroundColor,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/transfer': (context) => const TransferScreen(),
          '/success': (context) => const SuccessScreen(),
          '/risk-alerts': (context) => const RiskAlertsScreen(),
        },
      ),
    );
  }
}
