import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/extensions/extensions.dart';
import '../../../models/test_record.dart';
import '../../../repositories/test_repository.dart';
import '../../../shared/widgets/status_badges.dart';
import '../../../shared/widgets/test_card.dart';
import '../../../shared/widgets/app_states.dart';
import '../../auth/controllers/auth_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> _stats = {};
  List<TestRecord> _recentTests = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Get stats from mock
      _stats = {'total': 5, 'positive': 2, 'negative': 2, 'inconclusive': 1};

      // For recent records, we use the mock data directly
      _recentTests = _getMockRecent();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<TestRecord> _getMockRecent() {
    return [
      TestRecord(
        testId: 'TEST-2026-003',
        result: TestResult.inconclusive,
        operatorId: 'OP-1042',
        timestamp: DateTime(2026, 9, 29, 13, 25),
        latitude: 28.4600,
        longitude: 77.0200,
        imagePath: 'mock://image_003.jpg',
        imageHash: 'c5f6d4e3a7b8c9d0e1f2a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5',
        digitalSignature: 'PENDING',
        verificationStatus: VerificationStatus.pending,
      ),
      TestRecord(
        testId: 'TEST-2026-002',
        result: TestResult.negative,
        operatorId: 'OP-1044',
        timestamp: DateTime(2026, 9, 29, 13, 5),
        latitude: 28.4700,
        longitude: 77.0300,
        imagePath: 'mock://image_002.jpg',
        imageHash: 'b4e5c3d2f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3',
        digitalSignature: 'VALID',
        verificationStatus: VerificationStatus.verified,
      ),
      TestRecord(
        testId: 'TEST-2026-001',
        result: TestResult.positive,
        operatorId: 'OP-1042',
        timestamp: DateTime(2026, 9, 29, 12, 30),
        latitude: 28.4595,
        longitude: 77.0266,
        imagePath: 'mock://image_001.jpg',
        imageHash: 'a3f4b2c1d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2',
        digitalSignature: 'VALID',
        verificationStatus: VerificationStatus.verified,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final operator = auth.operator;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.biotech_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            const Text('Field Drug Test'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                operator?.avatarInitials ?? 'OP',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 8),
                    Text(operator?.name ?? 'Operator'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (v) async {
              if (v == 'logout') {
                await context.read<AuthController>().logout();
                if (mounted) context.go(RouteNames.login);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const AppLoadingState(message: 'Loading dashboard...')
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadData)
              : _buildBody(theme, operator),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouteNames.cameraCapture),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('New Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home is index 0
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user_outlined), label: 'Verify'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) context.go(RouteNames.testHistory);
          if (index == 2) context.go('${RouteNames.qrVerification}?mode=verify');
          if (index == 3) {} // Profile placeholder
        },
      ),
    );
  }

  Widget _buildBody(ThemeData theme, operator) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildStatsGrid(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildQuickActions(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildRecentTests(theme),
            const SizedBox(height: 80), // FAB clearance
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(ThemeData theme) {
    final auth = context.watch<AuthController>();
    final op = auth.operator;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              op?.avatarInitials ?? 'OP',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${op?.name.split(' ').first ?? 'Operator'}',
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${op?.id ?? ''} · ${op?.unit ?? ''}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  DateTime.now().toDisplayString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.negative.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.negative,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'ON DUTY',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.negative,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final stats = [
      {
        'label': 'Total Tests',
        'value': '${_stats['total'] ?? 0}',
        'icon': Icons.science_outlined,
        'color': AppColors.primary,
      },
      {
        'label': 'Positive',
        'value': '${_stats['positive'] ?? 0}',
        'icon': Icons.warning_rounded,
        'color': AppColors.positive,
      },
      {
        'label': 'Negative',
        'value': '${_stats['negative'] ?? 0}',
        'icon': Icons.check_circle_outline,
        'color': AppColors.negative,
      },
      {
        'label': 'Inconclusive',
        'value': '${_stats['inconclusive'] ?? 0}',
        'icon': Icons.help_outline,
        'color': AppColors.inconclusive,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.6,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) {
        final s = stats[i];
        final color = s['color'] as Color;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(s['icon'] as IconData, color: color, size: 18),
                    const Spacer(),
                    Text(
                      s['value'] as String,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  s['label'] as String,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.history_rounded,
            label: 'Test History',
            onTap: () => context.go(RouteNames.testHistory),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ActionButton(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Verify Record',
            onTap: () => context.go(
                '${RouteNames.qrVerification}?mode=verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTests(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Tests', style: theme.textTheme.titleSmall),
            TextButton(
              onPressed: () => context.go(RouteNames.testHistory),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_recentTests.isEmpty)
          const EmptyState(
            icon: Icons.science_outlined,
            title: 'No tests yet',
            subtitle: 'Start your first test using the button below.',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTests.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final record = _recentTests[i];
              return TestCard(
                record: record,
                compact: true,
                onTap: () =>
                    context.go(RouteNames.testDetails, extra: record),
              );
            },
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: theme.textTheme.labelMedium,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
