import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:billing_app/core/theme/app_theme.dart';

class ReportsHomePage extends StatelessWidget {
  const ReportsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.menu_rounded, color: theme.primaryColor),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            title: const Text('Reports & History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
          ),

          // Quick Stats Header
          SliverToBoxAdapter(child: _buildQuickStats(theme)),

          // Main Features Grid
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
              children: [
                _featureCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Bill History',
                  subtitle: 'View all past bills',
                  color: AppTheme.primaryColor,
                  gradient: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.7)],
                  onTap: () => context.push('/reports/bills'),
                ),
                _featureCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Daily Sales',
                  subtitle: 'Track daily revenue',
                  color: Colors.green,
                  gradient: [Colors.green, Colors.green.withValues(alpha: 0.7)],
                  onTap: () => context.push('/reports/daily-sales'),
                ),
                _featureCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Low Stock',
                  subtitle: 'Products running low',
                  color: Colors.orange,
                  gradient: [Colors.orange, Colors.orange.withValues(alpha: 0.7)],
                  onTap: () => context.push('/reports/low-stock'),
                ),
                _featureCard(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Stock Movement',
                  subtitle: 'Inventory changes',
                  color: Colors.blue,
                  gradient: [Colors.blue, Colors.blue.withValues(alpha: 0.7)],
                  onTap: () => context.push('/reports/stock-movements'),
                ),
                _featureCard(
                  icon: Icons.history_rounded,
                  title: 'Audit Trail',
                  subtitle: 'Activity timeline',
                  color: Colors.teal,
                  gradient: [Colors.teal, Colors.teal.withValues(alpha: 0.7)],
                  onTap: () => context.push('/reports/audit-trail'),
                ),
              ],
            ),
          ),

          // Quick Actions Section
          SliverToBoxAdapter(child: _buildQuickActions(theme, context)),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          _statItem(Icons.receipt_long_rounded, 'Reports', '4 sections'),
          Container(width: 1, height: 44, margin: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.1)]))),
          _statItem(Icons.analytics_rounded, 'Analytics', 'Real-time'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1)),
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
          ]),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (_, val, child) => Transform.scale(scale: val, child: child),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData t, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.flash_on_rounded, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Text('Quick Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.colorScheme.onSurface)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _quickAction('Bills', Icons.receipt_long_rounded, () => context.push('/reports/bills'))),
              const SizedBox(width: 10),
              Expanded(child: _quickAction('Sales', Icons.trending_up_rounded, () => context.push('/reports/daily-sales'))),
              const SizedBox(width: 10),
              Expanded(child: _quickAction('Stock', Icons.inventory_2_rounded, () => context.push('/reports/low-stock'))),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
        ),
        child: Column(children: [
          Icon(icon, size: 22, color: AppTheme.primaryColor),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
        ]),
      ),
    );
  }
}
