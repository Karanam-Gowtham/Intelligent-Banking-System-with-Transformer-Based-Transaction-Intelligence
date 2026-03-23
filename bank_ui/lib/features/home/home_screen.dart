import 'package:flutter/material.dart';
import '../../widgets/gradient_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good Morning",
                  style: TextStyle(fontSize: 20)),

              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5B8DEF), Color(0xFF7FAAFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Balance", style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 10),
                    Text("₹1,24,560",
                        style: TextStyle(
                            fontSize: 24, color: Colors.white)),
                  ],
                ),
              ),

              SizedBox(height: 20),

              GradientButton(
                text: "Send Money",
                onTap: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}