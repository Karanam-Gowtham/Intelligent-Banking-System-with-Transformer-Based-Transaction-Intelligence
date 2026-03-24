import 'package:flutter/material.dart';

class RiskAlertsScreen extends StatefulWidget {
  @override
  State<RiskAlertsScreen> createState() => _RiskAlertsScreenState();
}

class _RiskAlertsScreenState extends State<RiskAlertsScreen> {
  String selectedTab = 'Flagged';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Risk Alerts",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3B6B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Monitor suspicious activity",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _RiskTabButton(
                    label: "Flagged",
                    badge: "3",
                    isSelected: selectedTab == 'Flagged',
                    onTap: () => setState(() => selectedTab = 'Flagged'),
                  ),
                  SizedBox(width: 12),
                  _RiskTabButton(
                    label: "Blacklist",
                    badge: "2",
                    isSelected: selectedTab == 'Blacklist',
                    onTap: () => setState(() => selectedTab = 'Blacklist'),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Content
            Expanded(
              child: selectedTab == 'Flagged'
                  ? _FlaggedAlerts()
                  : _BlacklistAlerts(),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskTabButton extends StatelessWidget {
  final String label;
  final String badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _RiskTabButton({
    required this.label,
    required this.badge,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF5B8DEF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF5B8DEF) : Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Color(0xFF1A3B6B),
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Color(0xFFE74C3C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlaggedAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = [
      RiskAlert(
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
        title: "Binance",
        amount: "₹5,000",
        timestamp: "56:38 PM",
        riskLevel: "Medium",
        riskColor: Color(0xFFFF9800),
        source: "Late-work",
        description: "Unusually late transaction attempt",
        icon: Icons.schedule,
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          alerts.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _AlertCard(alert: alerts[index]),
          ),
        ),
      ),
    );
  }
}

class _BlacklistAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = [
      RiskAlert(
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          alerts.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: _AlertCard(alert: alerts[index]),
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final RiskAlert alert;

  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.riskColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alert.riskColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  alert.icon,
                  color: alert.riskColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A3B6B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      alert.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: alert.riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      alert.riskLevel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: alert.riskColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    alert.timestamp,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    alert.amount,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3B6B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Source",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    alert.source,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3B6B),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "More",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5B8DEF),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RiskAlert {
  final String title;
  final String amount;
  final String timestamp;
  final String riskLevel;
  final Color riskColor;
  final String source;
  final String description;
  final IconData icon;

  RiskAlert({
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
