import 'package:flutter/material.dart';

class RiskAlert {
  final String id;
  final String title;
  final String amount;
  final String timestamp;
  final String riskLevel;
  final Color riskColor;
  final String source;
  final String description;
  final IconData icon;

  RiskAlert({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
    required this.riskLevel,
    required this.riskColor,
    required this.source,
    required this.description,
    required this.icon,
  });
}
