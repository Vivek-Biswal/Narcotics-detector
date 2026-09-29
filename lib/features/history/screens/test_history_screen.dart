import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/history_controller.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../shared/widgets/app_states.dart';
import '../../../shared/widgets/test_card.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryController>().loadRecords();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = context.watch<HistoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.dashboard),
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(theme, ctrl),
          Expanded(child: _buildList(ctrl)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme, HistoryController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by ID / Operator / Location',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ctrl.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        ctrl.setSearchQuery('');
                      },
                    )
                  : null,
            ),
            onChanged: (val) {
              // Debounce in a real app
              ctrl.setSearchQuery(val);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: ctrl.resultFilter == null,
                  onSelected: () => ctrl.setResultFilter(null),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Positive',
                  isSelected: ctrl.resultFilter == TestResult.positive,
                  onSelected: () => ctrl.setResultFilter(TestResult.positive),
                  color: AppColors.positive,
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Negative',
                  isSelected: ctrl.resultFilter == TestResult.negative,
                  onSelected: () => ctrl.setResultFilter(TestResult.negative),
                  color: AppColors.negative,
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: 'Inconclusive',
                  isSelected: ctrl.resultFilter == TestResult.inconclusive,
                  onSelected: () =>
                      ctrl.setResultFilter(TestResult.inconclusive),
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(HistoryController ctrl) {
    if (ctrl.isLoading) {
      return const AppLoadingState(message: 'Loading records...');
    }

    if (ctrl.error != null) {
      return ErrorState(
        message: ctrl.error!,
        onRetry: () => ctrl.loadRecords(),
      );
    }

    if (ctrl.records.isEmpty) {
      return const EmptyState(
        icon: Icons.history_rounded,
        title: 'No records found',
        subtitle: 'Try adjusting your search or filters.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ctrl.loadRecords(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: ctrl.records.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final record = ctrl.records[index];
          return TestCard(
            record: record,
            onTap: () => context.go(RouteNames.testDetails, extra: record),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // History is index 1
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: 'Verify'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 0) context.go(RouteNames.dashboard);
        if (index == 2) context.go('${RouteNames.qrVerification}?mode=verify');
        if (index == 3) {} // Profile placeholder
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? AppColors.primary;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? activeColor : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
