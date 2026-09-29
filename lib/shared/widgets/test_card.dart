import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/extensions/extensions.dart';
import '../../models/test_record.dart';
import 'status_badges.dart';

/// Card displayed in test history list and recent tests on dashboard.
class TestCard extends StatelessWidget {
  final TestRecord record;
  final VoidCallback? onTap;
  final bool compact;

  const TestCard({
    super.key,
    required this.record,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      record.testId,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ResultBadge(result: record.result, compact: true),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(record.operatorId,
                      style: theme.textTheme.bodySmall),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      record.timestamp.toDisplayString(),
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(record.locationString,
                        style: theme.textTheme.bodySmall),
                    const Spacer(),
                    VerificationBadge(
                        status: record.verificationStatus, compact: true),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
