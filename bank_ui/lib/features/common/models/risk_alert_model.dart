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

  RiskAlert copyWith({
    String? id,
    String? title,
    String? amount,
    String? timestamp,
    String? riskLevel,
    Color? riskColor,
    String? source,
    String? description,
    IconData? icon,
  }) {
    return RiskAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      riskLevel: riskLevel ?? this.riskLevel,
      riskColor: riskColor ?? this.riskColor,
      source: source ?? this.source,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}
