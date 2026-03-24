import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/index.dart';
import 'features/common/providers/risk_alerts_provider.dart';
import 'features/common/risk_alerts_screen.dart';
import 'features/home/home_screen.dart';

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
          '/': (context) => HomeScreen(),
          '/risk-alerts': (context) => const RiskAlertsScreen(),
        },
      ),
    );
  }
}
