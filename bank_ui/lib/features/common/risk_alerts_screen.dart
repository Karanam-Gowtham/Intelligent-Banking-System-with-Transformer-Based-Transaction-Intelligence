import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/index.dart';
import 'models/risk_alert_model.dart';
import 'providers/risk_alerts_provider.dart';

enum _RiskAlertsTab { flagged, blacklist }

class RiskAlertsScreen extends StatefulWidget {
  const RiskAlertsScreen({super.key});

  @override
  State<RiskAlertsScreen> createState() => _RiskAlertsScreenState();
}

class _RiskAlertsScreenState extends State<RiskAlertsScreen> {
  _RiskAlertsTab _selectedTab = _RiskAlertsTab.flagged;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiskAlertsProvider>();
    final alerts = _selectedTab == _RiskAlertsTab.flagged
        ? provider.flaggedAlerts
        : provider.blacklistAlerts;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScreenHeader(
              flaggedCount: provider.flaggedCount,
              blacklistCount: provider.blacklistCount,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _RiskTabButton(
                      label: 'Flagged',
                      badge: provider.flaggedCount.toString(),
                      isSelected: _selectedTab == _RiskAlertsTab.flagged,
                      onTap: () {
                        setState(() {
                          _selectedTab = _RiskAlertsTab.flagged;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMd),
                  Expanded(
                    child: _RiskTabButton(
                      label: 'Blacklist',
                      badge: provider.blacklistCount.toString(),
                      isSelected: _selectedTab == _RiskAlertsTab.blacklist,
                      onTap: () {
                        setState(() {
                          _selectedTab = _RiskAlertsTab.blacklist;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLg),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.refreshAlerts,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _AlertsBody(
                    key: ValueKey<String>(
                      '${_selectedTab.name}-${provider.isLoading}-${alerts.length}',
                    ),
                    alerts: alerts,
                    isLoading: provider.isLoading,
                    error: provider.error,
                    selectedTab: _selectedTab,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({
    required this.flaggedCount,
    required this.blacklistCount,
  });

  final int flaggedCount;
  final int blacklistCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Alerts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            'Monitor suspicious activity before it becomes a customer issue.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextColor),
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Flagged today',
                  value: flaggedCount.toString(),
                  accentColor: AppColors.riskSuspicious,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: _MetricCard(
                  label: 'On blacklist',
                  value: blacklistCount.toString(),
                  accentColor: AppColors.riskBlocked,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertsBody extends StatelessWidget {
  const _AlertsBody({
    super.key,
    required this.alerts,
    required this.isLoading,
    required this.error,
    required this.selectedTab,
  });

  final List<RiskAlert> alerts;
  final bool isLoading;
  final String? error;
  final _RiskAlertsTab selectedTab;

  @override
  Widget build(BuildContext context) {
    if (isLoading && alerts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingXxl,
        ),
        children: const [
          SizedBox(height: 120),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (error != null && alerts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        children: [
          _StatusState(
            icon: Icons.cloud_off_rounded,
            title: 'Unable to load alerts',
            message: error!,
          ),
        ],
      );
    }

    if (alerts.isEmpty) {
      final title = selectedTab == _RiskAlertsTab.flagged
          ? 'No flagged alerts'
          : 'Blacklist is clear';
      final message = selectedTab == _RiskAlertsTab.flagged
          ? 'New suspicious activity will appear here when detected.'
          : 'Blocked entities will appear here after review.';

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        children: [
          _StatusState(
            icon: Icons.verified_user_outlined,
            title: title,
            message: message,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLg,
        0,
        AppDimensions.paddingLg,
        AppDimensions.paddingLg,
      ),
      itemCount: alerts.length,
      separatorBuilder: (_, index) =>
          const SizedBox(height: AppDimensions.paddingMd),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _AlertCard(
          alert: alert,
          isFlagged: selectedTab == _RiskAlertsTab.flagged,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.lightTextColor),
          ),
          const SizedBox(height: AppDimensions.paddingSm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.darkTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskTabButton extends StatelessWidget {
  const _RiskTabButton({
    required this.label,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String badge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLg,
          vertical: AppDimensions.paddingMd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.whiteColor
                    : AppColors.darkTextColor,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSm,
                vertical: AppDimensions.paddingXs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.whiteColor.withValues(alpha: 0.18)
                    : AppColors.riskBlocked,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.isFlagged});

  final RiskAlert alert;
  final bool isFlagged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: alert.riskColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                decoration: BoxDecoration(
                  color: alert.riskColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(
                  alert.icon,
                  color: alert.riskColor,
                  size: AppDimensions.iconMedium,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextColor,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXs),
                    Text(
                      alert.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSm,
                      vertical: AppDimensions.paddingXs,
                    ),
                    decoration: BoxDecoration(
                      color: alert.riskColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    child: Text(
                      alert.riskLevel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: alert.riskColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSm),
                  Text(
                    alert.timestamp,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.greyText),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          Row(
            children: [
              Expanded(
                child: _DetailItem(label: 'Amount', value: alert.amount),
              ),
              Expanded(
                child: _DetailItem(label: 'Source', value: alert.source),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<RiskAlertsProvider>().dismissAlert(alert.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${alert.title} dismissed.')),
                    );
                  },
                  child: const Text('Dismiss'),
                ),
              ),
              if (isFlagged) ...[
                const SizedBox(width: AppDimensions.paddingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final moved = context
                          .read<RiskAlertsProvider>()
                          .addToBlacklist(alert.id);
                      if (!moved) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${alert.title} added to blacklist.'),
                        ),
                      );
                    },
                    child: const Text('Blacklist'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.lightTextColor),
        ),
        const SizedBox(height: AppDimensions.paddingXs),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextColor,
          ),
        ),
      ],
    );
  }
}

class _StatusState extends StatelessWidget {
  const _StatusState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.all(AppDimensions.paddingXxl),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.primaryBlue),
          const SizedBox(height: AppDimensions.paddingMd),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextColor),
          ),
        ],
      ),
    );
  }
}
