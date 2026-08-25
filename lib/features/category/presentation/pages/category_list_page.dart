import 'package:flutter/material.dart';
import '../../../../core/widgets/adaptive_app_bar_leading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../bloc/category_bloc.dart';
import '../../domain/entities/category.dart';
import '../../../../core/theme/app_colors.dart';
import 'add_edit_category_dialog.dart';
import '../../../product/presentation/bloc/product_bloc.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _sortAscending = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  late AnimationController _headerAnimController;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.toLowerCase()));
    _headerAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  List<Category> _sorted(List<Category> cats) {
    final s = List<Category>.from(cats);
    s.sort((a, b) => _sortAscending
        ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
        : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    return s;
  }

  int _count(Category c) {
    try {
      return context.read<ProductBloc>().state.products.where((p) => p.categoryId == c.id).length;
    } catch (_) {
      return 0;
    }
  }

  int get _totalProducts {
    try {
      return context.read<ProductBloc>().state.products.length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cats = context.watch<CategoryBloc>().state.categories;

    return Scaffold(
      backgroundColor: t.scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Modern AppBar ───
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: t.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            leading: _isSelectionMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() {
                      _isSelectionMode = false;
                      _selectedIds.clear();
                    }),
                  )
                : const AdaptiveAppBarLeading(),
            title: _isSelectionMode
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text('${_selectedIds.length} selected',
                        key: ValueKey(_selectedIds.length),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  )
                : const Text('Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            actions: [
              if (_isSelectionMode)
                IconButton(
                  icon: Icon(Icons.delete_sweep_rounded,
                      color: _selectedIds.isNotEmpty ? t.colorScheme.error : t.colorScheme.onSurfaceVariant),
                  onPressed: _selectedIds.isEmpty ? null : _bulkDelete,
                )
              else ...[
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _sortAscending ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      key: ValueKey(_sortAscending),
                      color: t.colorScheme.onSurface,
                      size: 22,
                    ),
                  ),
                  onPressed: () => setState(() => _sortAscending = !_sortAscending),
                  tooltip: _sortAscending ? 'A → Z' : 'Z → A',
                ),
                IconButton(
                  icon: Icon(Icons.checklist_rounded, color: t.colorScheme.onSurface, size: 22),
                  onPressed: () => setState(() => _isSelectionMode = true),
                  tooltip: 'Multi-select',
                ),
              ],
            ],
          ),

          // ─── Search Bar ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: TextStyle(color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: Icon(Icons.search_rounded, color: t.colorScheme.onSurfaceVariant, size: 22),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  ),
                ),
              ),
            ),
          ),

          // ─── Stats Card ───
          SliverToBoxAdapter(child: _buildStatsCard(t, cats)),

          // ─── Recently Used ───
          SliverToBoxAdapter(child: _buildRecentlyUsed(t, cats)),

          // ─── Section Title ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Text('All Categories',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: t.colorScheme.onSurface)),
                  const Spacer(),
                  Text(
                    '${cats.length} ${cats.length == 1 ? "item" : "items"}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: t.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

          // ─── Category List ───
          BlocConsumer<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state.status == CategoryStatus.success && state.message != null) {
                AppFeedback.success(context, state.message!);
              }
            },
            builder: (context, state) {
              if (state.status == CategoryStatus.loading && state.categories.isEmpty) {
                return const SliverFillRemaining(
                  child: SingleChildScrollView(child: AppSkeletonList(itemCount: 5)),
                );
              }

              if (state.categories.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState(t));
              }

              final filtered = state.categories.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();
              final sorted = _sorted(filtered);

              if (sorted.isEmpty) {
                return SliverFillRemaining(child: _buildEmptySearch(t));
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = sorted[index];
                    final count = _count(cat);
                    final selected = _selectedIds.contains(cat.id);

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 350 + (index * 60).clamp(0, 600)),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - val)),
                          child: Opacity(opacity: val, child: child),
                        );
                      },
                      child: Dismissible(
                        key: Key(cat.id),
                        direction: _isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          HapticFeedback.heavyImpact();
                          return await _confirmSwipeDelete(cat);
                        },
                        onDismissed: (_) => context.read<CategoryBloc>().add(DeleteCategory(cat.id)),
                        background: _swipeBackground(t),
                        child: _categoryCard(cat, count, selected, t),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STATS CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsCard(ThemeData t, List<Category> cats) {
    return AnimatedBuilder(
      animation: _headerAnimController,
      builder: (context, _) {
        final anim = CurvedAnimation(parent: _headerAnimController, curve: Curves.easeOutCubic);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _statBlock((_totalProducts * anim.value).toInt(), 'Products', Icons.inventory_2_rounded),
                Container(
                  width: 1, height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.onAccent.withValues(alpha: 0.1), AppColors.onAccent.withValues(alpha: 0.35), AppColors.onAccent.withValues(alpha: 0.1)],
                    ),
                  ),
                ),
                _statBlock((cats.length * anim.value).toInt(), 'Categories', Icons.category_rounded),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statBlock(int value, String label, IconData icon) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.onAccent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.onAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: const TextStyle(color: AppColors.onAccent, fontSize: 26, fontWeight: FontWeight.w800, height: 1.0)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: AppColors.onAccent.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  RECENTLY USED
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecentlyUsed(ThemeData t, List<Category> cats) {
    if (cats.isEmpty) return const SizedBox.shrink();
    final top = List<Category>.from(cats)..sort((a, b) => _count(b).compareTo(_count(a)));
    final items = top.where((c) => _count(c) > 0).take(5).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.accentText(t.brightness)),
              ),
              const SizedBox(width: 8),
              Text('Top Categories',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final cat = items[i];
              final count = _count(cat);
              final color = Color(cat.colorValue);
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + i * 100),
                curve: Curves.easeOutBack,
                builder: (_, val, child) => Transform.scale(scale: val, child: child),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.read<ProductBloc>().add(FilterByCategory(cat.id));
                    context.go('/products');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ignore: non_const_argument_for_const_parameter
                        Icon(IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'), size: 15, color: color),
                        const SizedBox(width: 6),
                        Text(cat.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  CATEGORY CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _categoryCard(Category cat, int count, bool selected, ThemeData t) {
    final color = Color(cat.colorValue);
    // ignore: non_const_argument_for_const_parameter
    final icon = IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        if (!_isSelectionMode) {
          setState(() {
            _isSelectionMode = true;
            _selectedIds.add(cat.id);
          });
        }
      },
      onTap: () {
        HapticFeedback.lightImpact();
        if (_isSelectionMode) {
          setState(() {
            if (_selectedIds.contains(cat.id)) {
              _selectedIds.remove(cat.id);
              if (_selectedIds.isEmpty) _isSelectionMode = false;
            } else {
              _selectedIds.add(cat.id);
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.04) : t.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.4) : t.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? color.withValues(alpha: 0.12)
                  : t.colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: selected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_isSelectionMode) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  key: ValueKey(selected),
                  color: selected ? color : t.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
            ],

            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: -0.2)),
                  if (cat.description != null && cat.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(cat.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, color: t.colorScheme.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 13, color: color),
                        const SizedBox(width: 5),
                        Text('$count ${count == 1 ? "product" : "products"}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            if (!_isSelectionMode)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(Icons.edit_rounded, color, () => _openAddEditDialog(category: cat)),
                  const SizedBox(width: 8),
                  _iconBtn(Icons.delete_outline_rounded, t.colorScheme.error, () => _confirmDelete(cat)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  SWIPE BACKGROUND
  // ═══════════════════════════════════════════════════════════════
  Widget _swipeBackground(ThemeData t) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [t.colorScheme.error.withValues(alpha: 0.6), t.colorScheme.error],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
          const SizedBox(height: 4),
          Text('Delete', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  EMPTY STATES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEmptyState(ThemeData t) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (_, val, child) => Transform.scale(scale: val, child: child),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.elasticOut,
                builder: (_, val, child) => Transform.scale(scale: val, child: child),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent.withValues(alpha: 0.12), AppColors.accent.withValues(alpha: 0.04)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.category_rounded, size: 56, color: AppColors.accentText(t.brightness)),
                ),
              ),
              const SizedBox(height: 32),
              Text('No Categories Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: t.colorScheme.onSurface)),
              const SizedBox(height: 10),
              Text('Create categories to organize\nyour products better',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: t.colorScheme.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _openAddEditDialog(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create First Category', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearch(ThemeData t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: t.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('No categories match your search.',
              style: TextStyle(color: t.colorScheme.onSurfaceVariant, fontSize: 15)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  DIALOGS
  // ═══════════════════════════════════════════════════════════════
  void _confirmDelete(Category cat) {
    final t = Theme.of(context);
    final count = _count(cat);
    final color = Color(cat.colorValue);
    // ignore: non_const_argument_for_const_parameter
    final icon = IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: t.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.delete_outline_rounded, color: t.colorScheme.error, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Text('Delete Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 14),
            Text('Are you sure you want to delete this category?',
                style: TextStyle(fontSize: 14, color: t.colorScheme.onSurfaceVariant)),
            if (count > 0) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warningText(t.brightness), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '$count ${count == 1 ? "product" : "products"} will become uncategorized.',
                        style: TextStyle(fontSize: 13, color: AppColors.warningText(t.brightness), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: t.colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CategoryBloc>().add(DeleteCategory(cat.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: t.colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmSwipeDelete(Category cat) async {
    final count = _count(cat);
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Category'),
        content: Text(count > 0
            ? '"${cat.name}" has $count products. Delete anyway?'
            : 'Delete "${cat.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void _bulkDelete() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete $count ${count == 1 ? "category" : "categories"}?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete All', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final bloc = context.read<CategoryBloc>();
      for (final id in _selectedIds) {
        bloc.add(DeleteCategory(id));
      }
      setState(() {
        _isSelectionMode = false;
        _selectedIds.clear();
      });
    }
  }

  void _openAddEditDialog({Category? category}) {
    showDialog(
      context: context,
      builder: (_) => AddEditCategoryDialog(category: category),
    );
  }
}
