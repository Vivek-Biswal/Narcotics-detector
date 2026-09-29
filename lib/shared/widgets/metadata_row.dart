import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// A consistent metadata row (label + value) used in Record/Details screens.
class MetadataRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool monospace;
  final Widget? trailing;

  const MetadataRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.monospace = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.sm),
          ],
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: monospace ? 'monospace' : null,
                fontSize: monospace ? 11 : null,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Divider between metadata sections.
class MetadataDivider extends StatelessWidget {
  const MetadataDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 24, thickness: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.dividerDark
          : AppColors.dividerLight,
    );
  }
}

/// Section header in records/details screen.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
