import 'package:flutter/material.dart';

import '../../widgets/gradient_button.dart';
import '../../widgets/input_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const CustomInput(hint: 'Email'),
            const SizedBox(height: 15),
            const CustomInput(hint: 'Password'),
            const SizedBox(height: 25),
            GradientButton(
              text: 'Login',
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
