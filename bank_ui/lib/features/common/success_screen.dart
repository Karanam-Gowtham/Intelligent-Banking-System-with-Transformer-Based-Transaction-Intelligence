import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text('Payment Successful', style: TextStyle(fontSize: 20)),
            Text('Rs 5,000', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
