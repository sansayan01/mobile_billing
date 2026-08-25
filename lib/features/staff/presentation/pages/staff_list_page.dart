import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../bloc/staff_bloc.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    context.read<StaffBloc>().add(LoadStaff());
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const AdaptiveAppBarLeading(),
        title: const Text('Staff'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextFormField(
              controller: _searchController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Search staff...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary(b),
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocConsumer<StaffBloc, StaffState>(
              listener: (context, state) {
                if (state.status == StaffStatus.success &&
                    state.message != null) {
                  AppFeedback.success(context, state.message!);
                } else if (state.status == StaffStatus.error &&
                    state.message != null) {
                  AppFeedback.error(context, state.message!);
                }
              },
              builder: (context, state) {
                if (state.status == StaffStatus.loading &&
                    state.staff.isEmpty) {
                  return const SingleChildScrollView(
                    child: AppSkeletonList(itemCount: 5),
                  );
                }

                if (state.staff.isEmpty) {
                  if (state.status == StaffStatus.error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 56,
                                color: AppColors.textTertiary(b)),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary(b),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded,
                            size: 56, color: AppColors.textTertiary(b)),
                        const SizedBox(height: 16),
                        Text(
                          'No staff found',
                          style: TextStyle(
                            color: AppColors.textSecondary(b),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final filteredStaff = state.staff
                    .where((user) =>
                        user.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredStaff.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 56, color: AppColors.textTertiary(b)),
                        const SizedBox(height: 16),
                        Text(
                          'No staff match your search.',
                          style: TextStyle(
                            color: AppColors.textSecondary(b),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 12, bottom: 100),
                  itemCount: filteredStaff.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildStaffCard(context, filteredStaff[index], b),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, User user, Brightness b) {
    final isOwnerRole = user.role.toLowerCase() == 'owner';
    final badgeColor = isOwnerRole ? AppColors.success : AppColors.info;
    final badgeTextColor =
        isOwnerRole ? AppColors.successText(b) : AppColors.infoText(b);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(b)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading initials chip
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentSubtle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(user.name),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: AppColors.accentText(b),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.textPrimary(b),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.mail_outline_rounded,
                        size: 13, color: AppColors.textTertiary(b)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textTertiary(b),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                if (user.phone != null && user.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 13, color: AppColors.textTertiary(b)),
                      const SizedBox(width: 6),
                      Text(
                        user.phone!,
                        style: TextStyle(
                          color: AppColors.textTertiary(b),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.error(b).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: AppColors.error(b), size: 20),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              onPressed: () => _confirmDelete(context, user),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: const Text('Delete Staff'),
          content:
              Text('Are you sure you want to delete "${user.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<StaffBloc>().add(DeleteStaffMember(user.id));
                Navigator.pop(innerContext);
              },
              child: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );
  }
}
