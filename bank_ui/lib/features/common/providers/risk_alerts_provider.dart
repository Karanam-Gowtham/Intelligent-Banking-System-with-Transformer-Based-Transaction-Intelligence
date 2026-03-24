import 'package:flutter/material.dart';
import '../models/risk_alert_model.dart';

class RiskAlertsProvider extends ChangeNotifier {
  List<RiskAlert> _flaggedAlerts = [];
  List<RiskAlert> _blacklistAlerts = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RiskAlert> get flaggedAlerts => _flaggedAlerts;
  List<RiskAlert> get blacklistAlerts => _blacklistAlerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get flaggedCount => _flaggedAlerts.length;
  int get blacklistCount => _blacklistAlerts.length;

  RiskAlertsProvider() {
    _initializeData();
  }

  void _initializeData() {
    _setLoading(true);
    Future.delayed(Duration(milliseconds: 500), () {
      _flaggedAlerts = [
        RiskAlert(
          id: '1',
          title: "Coinbase",
          amount: "₹10,000",
          timestamp: "11:45 AM",
          riskLevel: "Suspicious",
          riskColor: Color(0xFFFF9800),
          source: "Cryptocurrency",
          description: "Unusual transaction to crypto exchange",
          icon: Icons.trending_up,
        ),
        RiskAlert(
          id: '2',
          title: "Kraken",
          amount: "₹15,000",
          timestamp: "09:30 AM",
          riskLevel: "High",
          riskColor: Color(0xFFE74C3C),
          source: "Crypto",
          description: "Rare destination - crypto wallet detected",
          icon: Icons.warning,
        ),
        RiskAlert(
          id: '3',
          title: "Binance",
          amount: "₹5,000",
          timestamp: "08:38 PM",
          riskLevel: "Medium",
          riskColor: Color(0xFFFF9800),
          source: "Late-work",
          description: "Unusually late transaction attempt",
          icon: Icons.schedule,
        ),
      ];

      _blacklistAlerts = [
        RiskAlert(
          id: '4',
          title: "Unknown Transfer",
          amount: "Blocked",
          timestamp: "2 days ago",
          riskLevel: "Blocked",
          riskColor: Color(0xFFE74C3C),
          source: "Suspicious",
          description: "Account added to blacklist",
          icon: Icons.block,
        ),
        RiskAlert(
          id: '5',
          title: "Fraudulent Address",
          amount: "Blocked",
          timestamp: "1 week ago",
          riskLevel: "Blocked",
          riskColor: Color(0xFFE74C3C),
          source: "Merchant",
          description: "Flagged as fraudulent merchant",
          icon: Icons.error,
        ),
      ];

      _setLoading(false);
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _error = null;
    }
  }

  void dismissAlert(String alertId) {
    _flaggedAlerts.removeWhere((alert) => alert.id == alertId);
    _blacklistAlerts.removeWhere((alert) => alert.id == alertId);
    notifyListeners();
  }

  void addToBlacklist(String alertId) {
    final alert = _flaggedAlerts.firstWhere(
      (alert) => alert.id == alertId,
      orElse: () => throw Exception('Alert not found'),
    );
    _flaggedAlerts.removeWhere((a) => a.id == alertId);
    _blacklistAlerts.add(alert);
    notifyListeners();
  }

  void refreshAlerts() {
    _initializeData();
  }
}
