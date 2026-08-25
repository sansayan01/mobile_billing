import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_settings/app_settings.dart';

import '../../../../core/navigation/navigation_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  PrinterStatus _lastPrinterStatus = PrinterStatus.initial;

  @override
  void initState() {
    super.initState();
    context.read<PrinterBloc>().add(InitPrinterEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const AdaptiveAppBarLeading(),
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              width: double.infinity,
              color: theme.colorScheme.surface,
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: BlocBuilder<ShopBloc, ShopState>(
                builder: (context, state) {
                  String shopName = 'Your Shop';
                  String initials = 'S';
                  if (state is ShopLoaded && state.shop.name.isNotEmpty) {
                    shopName = state.shop.name;
                    final parts = shopName.split(' ');
                    initials = parts
                        .take(2)
                        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                        .join('');
                    if (initials.isEmpty) initials = 'S';
                  }

                  return Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent
                                    .withValues(alpha: 0.2),
                                blurRadius: 15,
                                spreadRadius: 5,
                              )
                            ]),
                        alignment: Alignment.center,
                        child: Text(initials,
                            style: const TextStyle(
                                color: AppColors.onAccent,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1)),
                      ),
                      const SizedBox(height: 16),
                      Text(shopName.toUpperCase(),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface)),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Appearance Section ──
            _buildSectionHeader('Appearance'),
            _buildListGroup(
              theme: theme,
              children: [
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return _buildSwitchItem(
                      theme: theme,
                      icon: Icons.dark_mode,
                      title: 'Dark Mode',
                      subtitle: themeMode == ThemeMode.dark
                          ? 'Dark theme is enabled'
                          : 'Use light theme',
                      value: themeMode == ThemeMode.dark,
                      onChanged: (val) =>
                          context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),
                BlocBuilder<NavigationCubit, AppNavigationMode>(
                  builder: (context, navMode) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accentSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.swap_horiz_rounded,
                                  color: AppColors.accentText(theme.brightness),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Navigation Style',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color:
                                                theme.colorScheme.onSurface)),
                                    const SizedBox(height: 2),
                                    Text(
                                      navMode == AppNavigationMode.bottomNav
                                          ? 'Bottom bar with quick actions'
                                          : 'Classic hamburger menu',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: theme
                                              .colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<AppNavigationMode>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: AppNavigationMode.bottomNav,
                                  icon: Icon(Icons.space_dashboard_rounded,
                                      size: 18),
                                  label: Text('Bottom Bar'),
                                ),
                                ButtonSegment(
                                  value: AppNavigationMode.drawer,
                                  icon: Icon(Icons.menu_rounded, size: 18),
                                  label: Text('Hamburger'),
                                ),
                              ],
                              selected: {navMode},
                              onSelectionChanged: (selection) {
                                HapticFeedback.selectionClick();
                                context
                                    .read<NavigationCubit>()
                                    .setMode(selection.first);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Management Section
            _buildSectionHeader('Management'),
            _buildListGroup(
              theme: theme,
              children: [
                _buildListItem(
                  theme: theme,
                  icon: Icons.storefront,
                  title: 'Shop Details',
                  subtitle: 'Edit business info & address',
                  onTap: () => context.push('/shop'),
                ),
                _buildListItem(
                  theme: theme,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  iconColor: theme.colorScheme.error,
                  onTap: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hardware Section
            _buildSectionHeader('Hardware'),
            BlocConsumer<PrinterBloc, PrinterState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  AppFeedback.error(context, state.errorMessage!);
                } else if (state.status == PrinterStatus.connected) {
                  AppFeedback.success(context, 'Connected to printer');
                } else if (state.status == PrinterStatus.scanSuccess &&
                    _lastPrinterStatus == PrinterStatus.testPrinting) {
                  AppFeedback.success(context, 'Test print sent');
                }
                _lastPrinterStatus = state.status;
              },
              builder: (context, state) {
                return _buildListGroup(
                  theme: theme,
                  children: [
                    _buildListItem(
                      theme: theme,
                      icon: Icons.print,
                      title: 'Print Device',
                      subtitleWidget: Row(
                        children: [
                          Text(
                            state.connectedMac != null
                                ? (state.connectedName ?? 'Printer connected')
                                : 'No printer connected',
                            style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                          if (state.connectedMac != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: AppColors.success.withValues(alpha: 0.3))),
                              child: Text(
                                'CONNECTED',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.successText(theme.brightness)),
                              ),
                            ),
                          ]
                        ],
                      ),
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.status == PrinterStatus.scanning ||
                              state.status == PrinterStatus.connecting)
                            const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                          else
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => context
                                  .read<PrinterBloc>()
                                  .add(RefreshPrinterEvent()),
                              color: AppColors.accentText(theme.brightness),
                            ),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              AppSettings.openAppSettings(
                                  type: AppSettingsType.bluetooth);
                            },
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    _buildListItem(
                      theme: theme,
                      icon: Icons.bluetooth_searching_rounded,
                      title: 'Scan Devices',
                      subtitle: 'Pick a paired Bluetooth printer to connect',
                      onTap: () => _showScanSheet(context, theme),
                    ),
                    _buildListItem(
                      theme: theme,
                      icon: Icons.print_rounded,
                      title: 'Test Print',
                      subtitle: state.connectedMac != null
                          ? 'Print a sample line to verify output'
                          : 'Connect a printer first',
                      onTap: state.connectedMac != null &&
                              state.status != PrinterStatus.testPrinting
                          ? () {
                              HapticFeedback.selectionClick();
                              final shopState = context.read<ShopBloc>().state;
                              final shopName = shopState is ShopLoaded &&
                                      shopState.shop.name.isNotEmpty
                                  ? shopState.shop.name
                                  : 'My Shop';
                              context
                                  .read<PrinterBloc>()
                                  .add(TestPrintEvent(shopName));
                            }
                          : null,
                      trailingWidget:
                          state.status == PrinterStatus.testPrinting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : null,
                      trailingIcon:
                          state.status == PrinterStatus.testPrinting
                              ? null
                              : Icons.chevron_right,
                    ),
                    if (state.connectedMac != null)
                      _buildListItem(
                        theme: theme,
                        icon: Icons.link_off_rounded,
                        title: 'Disconnect',
                        subtitle: 'Unpair the current printer',
                        iconColor: theme.colorScheme.error,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<PrinterBloc>()
                              .add(DisconnectPrinterEvent());
                        },
                      ),
                  ],
                );
              },
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                "Tap Scan Devices to pick from already-paired Bluetooth printers. To pair a new one, use the Settings gear, pair it in phone's Bluetooth settings, then come back and scan.",
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ),

            const SizedBox(height: 96),
          ],
        ),
      ),
    );
  }

  void _showScanSheet(BuildContext context, ThemeData theme) {
    final printerBloc = context.read<PrinterBloc>();
    printerBloc.add(ScanPrintersEvent());
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface(theme.brightness),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => BlocBuilder<PrinterBloc, PrinterState>(
        bloc: printerBloc,
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Paired Devices',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color:
                                  AppColors.textPrimary(theme.brightness))),
                      const Spacer(),
                      if (state.status == PrinterStatus.scanning)
                        const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: () =>
                              printerBloc.add(ScanPrintersEvent()),
                          color: AppColors.accentText(theme.brightness),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (state.status == PrinterStatus.scanning &&
                      state.devices.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.devices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No paired devices found. Pair your printer in Bluetooth settings first.',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary(theme.brightness)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.devices.length,
                        itemBuilder: (context, i) {
                          final device = state.devices[i];
                          final isCurrent =
                              device.macAdress == state.connectedMac;
                          return ListTile(
                            leading: Icon(Icons.print_rounded,
                                color:
                                    AppColors.accentText(theme.brightness)),
                            title: Text(device.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(device.macAdress,
                                style: const TextStyle(fontSize: 11)),
                            trailing: isCurrent
                                ? Text('CONNECTED',
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.successText(
                                            theme.brightness)))
                                : null,
                            onTap: () {
                              Navigator.pop(sheetContext);
                              HapticFeedback.selectionClick();
                              printerBloc.add(ConnectPrinterEvent(
                                  mac: device.macAdress, name: device.name));
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildListGroup({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    Color? iconColor,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? trailingWidget,
    IconData? trailingIcon = Icons.chevron_right,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.accentText(theme.brightness), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: theme.colorScheme.onSurface)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                  if (subtitleWidget != null) ...[
                    const SizedBox(height: 4),
                    subtitleWidget,
                  ]
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else if (trailingIcon != null)
              Icon(trailingIcon, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accentText(theme.brightness), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
