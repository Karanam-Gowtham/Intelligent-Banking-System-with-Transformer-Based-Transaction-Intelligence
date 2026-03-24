import 'package:flutter/material.dart';

import '../../../core/constants/index.dart';
import '../models/risk_alert_model.dart';

class RiskAlertsProvider extends ChangeNotifier {
  List<RiskAlert> _flaggedAlerts = [];
  List<RiskAlert> _blacklistAlerts = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  List<RiskAlert> get flaggedAlerts => _flaggedAlerts;
  List<RiskAlert> get blacklistAlerts => _blacklistAlerts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  int get flaggedCount => _flaggedAlerts.length;
  int get blacklistCount => _blacklistAlerts.length;

  RiskAlertsProvider() {
    Future<void>.microtask(loadAlerts);
  }

  Future<void> loadAlerts({bool isRefresh = false}) async {
    _setLoading(true);
    notifyListeners();

    try {
      await Future<void>.delayed(Duration(milliseconds: isRefresh ? 250 : 500));
      _flaggedAlerts = _buildFlaggedAlerts();
      _blacklistAlerts = _buildBlacklistAlerts();
      _lastUpdated = DateTime.now();
      _error = null;
    } catch (_) {
      _error = 'Unable to load risk alerts right now.';
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  void dismissAlert(String alertId) {
    final flaggedBefore = _flaggedAlerts.length;
    final blacklistBefore = _blacklistAlerts.length;

    _flaggedAlerts.removeWhere((alert) => alert.id == alertId);
    _blacklistAlerts.removeWhere((alert) => alert.id == alertId);

    if (flaggedBefore != _flaggedAlerts.length ||
        blacklistBefore != _blacklistAlerts.length) {
      _touch();
      notifyListeners();
    }
  }

  bool addToBlacklist(String alertId) {
    final alertIndex = _flaggedAlerts.indexWhere(
      (alert) => alert.id == alertId,
    );
    if (alertIndex == -1) {
      return false;
    }

    final alert = _flaggedAlerts
        .removeAt(alertIndex)
        .copyWith(
          riskLevel: 'Blocked',
          riskColor: AppColors.riskBlocked,
          source: 'Manual block',
          timestamp: 'Just now',
          description:
              'Merchant moved to the blocked watchlist after analyst review.',
          icon: Icons.block_rounded,
        );

    _blacklistAlerts.insert(0, alert);
    _touch();
    notifyListeners();
    return true;
  }

  bool moveToFlaggedReview(String alertId) {
    final alertIndex = _blacklistAlerts.indexWhere(
      (alert) => alert.id == alertId,
    );
    if (alertIndex == -1) {
      return false;
    }

    final alert = _blacklistAlerts
        .removeAt(alertIndex)
        .copyWith(
          riskLevel: 'Review',
          riskColor: AppColors.riskSuspicious,
          source: 'Manual review',
          timestamp: 'Just now',
          amount: 'Pending review',
          description:
              'Merchant moved back to the flagged queue for analyst review.',
          icon: Icons.pending_actions_rounded,
        );

    _flaggedAlerts.insert(0, alert);
    _touch();
    notifyListeners();
    return true;
  }

  Future<void> refreshAlerts() {
    return loadAlerts(isRefresh: true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _error = null;
    }
  }

  void _touch() {
    _lastUpdated = DateTime.now();
  }

  List<RiskAlert> _buildFlaggedAlerts() {
    return [
      RiskAlert(
        id: '1',
        title: 'Coinbase',
        amount: 'Rs 10,000',
        timestamp: '11:45 AM',
        riskLevel: 'Suspicious',
        riskColor: AppColors.riskSuspicious,
        source: 'Cryptocurrency',
        description: 'Unusual transaction to crypto exchange.',
        icon: Icons.trending_up,
      ),
      RiskAlert(
        id: '2',
        title: 'Kraken',
        amount: 'Rs 15,000',
        timestamp: '09:30 AM',
        riskLevel: 'High',
        riskColor: AppColors.riskHigh,
        source: 'Crypto',
        description: 'Rare destination with a flagged wallet pattern.',
        icon: Icons.warning_amber_rounded,
      ),
      RiskAlert(
        id: '3',
        title: 'Binance',
        amount: 'Rs 5,000',
        timestamp: '08:38 PM',
        riskLevel: 'Medium',
        riskColor: AppColors.riskMedium,
        source: 'Late-hour transfer',
        description:
            'Unusually late transfer attempt outside the profile norm.',
        icon: Icons.schedule_rounded,
      ),
    ];
  }

  List<RiskAlert> _buildBlacklistAlerts() {
    return [
      RiskAlert(
        id: '4',
        title: 'Unknown Transfer',
        amount: 'Blocked',
        timestamp: '2 days ago',
        riskLevel: 'Blocked',
        riskColor: AppColors.riskBlocked,
        source: 'Suspicious',
        description: 'Account added to blacklist after manual review.',
        icon: Icons.block_rounded,
      ),
      RiskAlert(
        id: '5',
        title: 'Fraudulent Address',
        amount: 'Blocked',
        timestamp: '1 week ago',
        riskLevel: 'Blocked',
        riskColor: AppColors.riskBlocked,
        source: 'Merchant',
        description: 'Merchant has been marked as permanently blocked.',
        icon: Icons.gpp_bad_rounded,
      ),
    ];
  }
}
