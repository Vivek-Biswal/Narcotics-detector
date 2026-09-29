import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/enums/app_enums.dart';

/// Result badge widget — uses colour + icon + text for full accessibility.
class ResultBadge extends StatelessWidget {
  final TestResult result;
  final double fontSize;
  final bool compact;

  const ResultBadge({
    super.key,
    required this.result,
    this.fontSize = 13,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(result);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 16,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: (config['color'] as Color).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            color: config['color'] as Color,
            size: compact ? 14 : 16,
          ),
          const SizedBox(width: 6),
          Text(
            result.label,
            style: TextStyle(
              color: config['color'] as Color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> _getConfig(TestResult result) {
    switch (result) {
      case TestResult.positive:
        return {
          'color': AppColors.positive,
          'bg': AppColors.positiveLight,
          'icon': Icons.warning_rounded,
        };
      case TestResult.negative:
        return {
          'color': AppColors.negative,
          'bg': AppColors.negativeLight,
          'icon': Icons.check_circle_rounded,
        };
      case TestResult.inconclusive:
        return {
          'color': AppColors.inconclusive,
          'bg': AppColors.inconclusiveLight,
          'icon': Icons.help_rounded,
        };
    }
  }
}

/// Verification status badge.
class VerificationBadge extends StatelessWidget {
  final VerificationStatus status;
  final bool compact;

  const VerificationBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            color: config['color'] as Color,
            size: compact ? 12 : 14,
          ),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: config['color'] as Color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> _getConfig(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return {
          'color': AppColors.verified,
          'bg': AppColors.verifiedLight,
          'icon': Icons.verified_rounded,
        };
      case VerificationStatus.pending:
        return {
          'color': AppColors.pending,
          'bg': AppColors.pendingLight,
          'icon': Icons.pending_rounded,
        };
      case VerificationStatus.failed:
        return {
          'color': AppColors.failed,
          'bg': AppColors.failedLight,
          'icon': Icons.dangerous_rounded,
        };
    }
  }
}
