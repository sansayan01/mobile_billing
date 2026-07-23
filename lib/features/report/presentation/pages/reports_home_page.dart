import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/core/theme/app_theme.dart';

class ReportsHomePage extends StatefulWidget {
  const ReportsHomePage({super.key});

  @override
  State<ReportsHomePage> createState() => _ReportsHomePageState();
}

class _ReportsHomePageState extends State<ReportsHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).primaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: 'Open menu',
        ),
        title: const Text('Reports & History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
          children: [
            _buildCard(
              icon: Icons.receipt_long,
              title: 'Bill History',
              subtitle: 'View all past bills',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/reports/bills'),
            ),
            _buildCard(
              icon: Icons.trending_up,
              title: 'Daily Sales',
              subtitle: 'Track daily revenue',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/reports/daily-sales'),
            ),
            _buildCard(
              icon: Icons.inventory_2,
              title: 'Low Stock',
              subtitle: 'Products running low',
              color: AppTheme.errorColor,
              onTap: () => context.push('/reports/low-stock'),
            ),
            _buildCard(
              icon: Icons.history,
              title: 'Stock Movement',
              subtitle: 'Inventory changes',
              color: AppTheme.primaryColor,
              onTap: () => context.push('/reports/stock-movements'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
