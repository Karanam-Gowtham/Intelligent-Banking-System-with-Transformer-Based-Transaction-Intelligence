import 'package:flutter/material.dart';

import '../../widgets/gradient_button.dart';
import '../../widgets/input_field.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CustomInput(hint: 'Recipient'),
            const SizedBox(height: 10),
            const CustomInput(hint: 'Amount'),
            const SizedBox(height: 20),
            GradientButton(
              text: 'Confirm',
              onTap: () {
                Navigator.pushNamed(context, '/success');
              },
            ),
          ],
        ),
      ),
    );
  }
}
