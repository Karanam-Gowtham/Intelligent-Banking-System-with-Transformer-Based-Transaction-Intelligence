import 'package:flutter/material.dart';

import '../../widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Good Morning', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5B8DEF), Color(0xFF7FAAFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Balance', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 10),
                    Text(
                      'Rs 1,24,560',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Send Money',
                onTap: () {
                  Navigator.pushNamed(context, '/transfer');
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/risk-alerts');
                },
                icon: const Icon(Icons.shield_rounded),
                label: const Text('Risk Alerts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
