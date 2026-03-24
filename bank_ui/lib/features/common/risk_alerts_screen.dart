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

  Future<void> _refreshAlerts() async {
    final provider = context.read<RiskAlertsProvider>();
    await provider.refreshAlerts();
    if (!mounted) {
      return;
    }

    _showMessage('Risk alerts refreshed.');
  }

  void _dismissAlert(RiskAlert alert) {
    context.read<RiskAlertsProvider>().dismissAlert(alert.id);
    _showMessage('${alert.title} dismissed.');
  }

  void _moveToBlacklist(RiskAlert alert) {
    final moved = context.read<RiskAlertsProvider>().addToBlacklist(alert.id);
    if (moved) {
      _showMessage('${alert.title} added to blacklist.');
    }
  }

  void _moveToReview(RiskAlert alert) {
    final moved = context.read<RiskAlertsProvider>().moveToFlaggedReview(
      alert.id,
    );
    if (moved) {
      _showMessage('${alert.title} moved back to review.');
      setState(() {
        _selectedTab = _RiskAlertsTab.flagged;
      });
    }
  }

  void _openAlertDetails(RiskAlert alert, bool isFlagged) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AlertDetailsSheet(
          alert: alert,
          isFlagged: isFlagged,
          onDismiss: () {
            Navigator.of(sheetContext).pop();
            _dismissAlert(alert);
          },
          onPrimaryAction: () {
            Navigator.of(sheetContext).pop();
            if (isFlagged) {
              _moveToBlacklist(alert);
            } else {
              _moveToReview(alert);
            }
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) {
      return 'Syncing alerts';
    }

    final difference = DateTime.now().difference(lastUpdated);
    if (difference.inMinutes < 1) {
      return 'Updated just now';
    }
    if (difference.inHours < 1) {
      return 'Updated ${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return 'Updated ${difference.inHours}h ago';
    }
    return 'Updated ${difference.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RiskAlertsProvider>();
    final isFlaggedTab = _selectedTab == _RiskAlertsTab.flagged;
    final alerts = isFlaggedTab
        ? provider.flaggedAlerts
        : provider.blacklistAlerts;

    return Scaffold(
      body: Stack(
        children: [
          const _BackdropGlow(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScreenHeader(
                  flaggedCount: provider.flaggedCount,
                  blacklistCount: provider.blacklistCount,
                  lastUpdatedLabel: _formatLastUpdated(provider.lastUpdated),
                  onRefresh: _refreshAlerts,
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
                          isSelected: isFlaggedTab,
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
                          isSelected: !isFlaggedTab,
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
                _SectionHeader(isFlagged: isFlaggedTab),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshAlerts,
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
                        onRetry: _refreshAlerts,
                        onDismiss: _dismissAlert,
                        onPrimaryAction: isFlaggedTab
                            ? _moveToBlacklist
                            : _moveToReview,
                        onOpenDetails: _openAlertDetails,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -40,
          right: -40,
          child: Container(
            height: 260,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFD8E9FF), Color(0xFFF5F7FA)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 24,
          right: -10,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({
    required this.flaggedCount,
    required this.blacklistCount,
    required this.lastUpdatedLabel,
    required this.onRefresh,
  });

  final int flaggedCount;
  final int blacklistCount;
  final String lastUpdatedLabel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLg,
        AppDimensions.paddingLg,
        AppDimensions.paddingLg,
        AppDimensions.paddingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Alerts',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
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
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF16375E), Color(0xFF4A82CF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingMd),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.whiteColor,
                        size: AppDimensions.iconLarge,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRefresh,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.whiteColor.withValues(
                          alpha: 0.14,
                        ),
                        foregroundColor: AppColors.whiteColor,
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                Text(
                  flaggedCount == 0
                      ? 'Queues are clear'
                      : '$flaggedCount alerts need attention',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSm),
                Text(
                  'Review suspicious merchants, isolate blocked entities, and keep the payment flow safe.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Review queue',
                        value: flaggedCount.toString(),
                        accentColor: AppColors.whiteColor.withValues(
                          alpha: 0.22,
                        ),
                        darkBackground: true,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingMd),
                    Expanded(
                      child: _MetricCard(
                        label: 'Blocked',
                        value: blacklistCount.toString(),
                        accentColor: AppColors.whiteColor.withValues(
                          alpha: 0.22,
                        ),
                        darkBackground: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                Text(
                  lastUpdatedLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.whiteColor.withValues(alpha: 0.84),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
    required this.onRetry,
    required this.onDismiss,
    required this.onPrimaryAction,
    required this.onOpenDetails,
  });

  final List<RiskAlert> alerts;
  final bool isLoading;
  final String? error;
  final _RiskAlertsTab selectedTab;
  final Future<void> Function() onRetry;
  final ValueChanged<RiskAlert> onDismiss;
  final ValueChanged<RiskAlert> onPrimaryAction;
  final void Function(RiskAlert alert, bool isFlagged) onOpenDetails;

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
            actionLabel: 'Try again',
            onAction: onRetry,
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
            actionLabel: 'Refresh',
            onAction: onRetry,
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
          onDismiss: () => onDismiss(alert),
          onPrimaryAction: () => onPrimaryAction(alert),
          onOpenDetails: () =>
              onOpenDetails(alert, selectedTab == _RiskAlertsTab.flagged),
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
    this.darkBackground = false,
  });

  final String label;
  final String value;
  final Color accentColor;
  final bool darkBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: darkBackground
            ? AppColors.whiteColor.withValues(alpha: 0.1)
            : AppColors.whiteColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: darkBackground
                  ? AppColors.whiteColor.withValues(alpha: 0.76)
                  : AppColors.lightTextColor,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: darkBackground
                  ? AppColors.whiteColor
                  : AppColors.darkTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.isFlagged});

  final bool isFlagged;

  @override
  Widget build(BuildContext context) {
    final title = isFlagged ? 'Priority queue' : 'Blocked watchlist';
    final subtitle = isFlagged
        ? 'Focus on the newest alerts that need analyst review.'
        : 'These merchants are currently isolated from the payment flow.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingLg,
        AppDimensions.paddingLg,
        AppDimensions.paddingLg,
        AppDimensions.paddingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.darkTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXs),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.lightTextColor),
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
  const _AlertCard({
    required this.alert,
    required this.isFlagged,
    required this.onDismiss,
    required this.onPrimaryAction,
    required this.onOpenDetails,
  });

  final RiskAlert alert;
  final bool isFlagged;
  final VoidCallback onDismiss;
  final VoidCallback onPrimaryAction;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final primaryLabel = isFlagged ? 'Blacklist' : 'Move to review';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenDetails,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(20),
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkTextColor,
                              ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXs),
                        Text(
                          alert.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.lightTextColor),
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
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: alert.riskColor,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingSm),
                      Text(
                        alert.timestamp,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.greyText,
                        ),
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
              Wrap(
                spacing: AppDimensions.paddingSm,
                runSpacing: AppDimensions.paddingSm,
                alignment: WrapAlignment.end,
                children: [
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onOpenDetails,
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Details'),
                  ),
                  FilledButton(
                    onPressed: onPrimaryAction,
                    child: Text(primaryLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
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

class _AlertDetailsSheet extends StatelessWidget {
  const _AlertDetailsSheet({
    required this.alert,
    required this.isFlagged,
    required this.onDismiss,
    required this.onPrimaryAction,
  });

  final RiskAlert alert;
  final bool isFlagged;
  final VoidCallback onDismiss;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.paddingLg,
            AppDimensions.paddingMd,
            AppDimensions.paddingLg,
            AppDimensions.paddingLg,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSm),
                Text(
                  alert.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                _DetailTile(
                  label: 'Transaction value',
                  value: alert.amount,
                  icon: Icons.currency_rupee_rounded,
                ),
                _DetailTile(
                  label: 'Detection source',
                  value: alert.source,
                  icon: Icons.account_tree_outlined,
                ),
                _DetailTile(
                  label: 'Timeline',
                  value: alert.timestamp,
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                Text(
                  'Recommended action',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSm),
                Text(
                  isFlagged
                      ? 'Keep this merchant under review or isolate it immediately by moving it to the blacklist.'
                      : 'This merchant is blocked. Move it back into the review queue if another analyst pass is needed.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingLg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onPrimaryAction,
                    child: Text(
                      isFlagged ? 'Move to blacklist' : 'Move to review',
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingSm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: const Text('Dismiss alert'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSm),
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: AppDimensions.paddingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.lightTextColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusState extends StatelessWidget {
  const _StatusState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

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
          const SizedBox(height: AppDimensions.paddingLg),
          FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
