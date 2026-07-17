import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Billing App',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone & Accessories Shop',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan & Billing',
                  route: '/',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    if (currentRoute != '/') context.go('/');
                  },
                ),
                _DrawerItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Products',
                  route: '/products',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    context.go('/products');
                  },
                ),
                _DrawerItem(
                  icon: Icons.category_rounded,
                  label: 'Categories',
                  route: '/categories',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    context.go('/categories');
                  },
                ),
                _DrawerItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reports',
                  route: '/reports',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    context.go('/reports');
                  },
                ),
                _DrawerItem(
                  icon: Icons.store_rounded,
                  label: 'Shop Details',
                  route: '/shop',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    context.go('/shop');
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_rounded,
                  label: 'Printer Settings',
                  route: '/settings',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    context.go('/settings');
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.logout_rounded,
                      size: 18, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    context.pop();
                    // In future: dispatch LogoutRequested
                    context.go('/login');
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route ||
        (route != '/' && currentRoute.startsWith(route));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Theme.of(context).primaryColor : Colors.grey[600],
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Theme.of(context).primaryColor : Colors.black87,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
