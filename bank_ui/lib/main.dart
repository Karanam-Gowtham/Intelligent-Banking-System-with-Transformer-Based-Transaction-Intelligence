import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/index.dart';
import 'core/router/app_router.dart';
import 'features/common/providers/risk_alerts_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RiskAlertsProvider(),
      child: MaterialApp.router(
        title: 'Bank Risk Alerts',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryBlue,
            surface: AppColors.whiteColor,
          ),
          scaffoldBackgroundColor: AppColors.backgroundColor,
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
