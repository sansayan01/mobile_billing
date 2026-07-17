import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const _ProfileHeader(),

          // Menu Items (sectioned)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const _SectionHeader('Main'),
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  route: '/',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    if (currentRoute != '/') context.go('/');
                  },
                ),
                _DrawerItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scan & Billing',
                  route: '/scan',
                  currentRoute: currentRoute,
                  onTap: () {
                    context.pop();
                    context.go('/scan');
                  },
                ),
                const _SectionHeader('Inventory'),
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
                const _SectionHeader('Reports'),
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
                const _SectionHeader('Settings'),
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

          // Footer — Logout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                context.pop();
                // Redirect guard (AuthBloc -> Unauthenticated) sends to /login.
                context.read<AuthBloc>().add(const LogoutRequested());
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isAuth = state is Authenticated;
        final name = isAuth ? state.user.name : 'Billing App';
        final email = isAuth ? state.user.email : 'Phone & Accessories Shop';
        final role = isAuth ? state.user.role : null;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 24,
            bottom: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(color: theme.colorScheme.primary),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: isAuth
                        ? Text(
                            _initials(name),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.receipt_long_rounded,
                            size: 28, color: Colors.white),
                  ),
                  if (role != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: Colors.grey[500],
        ),
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
        color: isActive
            ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
            : null,
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
