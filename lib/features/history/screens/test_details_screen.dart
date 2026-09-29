import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/enums/app_enums.dart';
import '../../../models/test_record.dart';
import '../../../shared/widgets/status_badges.dart';
import '../../../shared/widgets/metadata_row.dart';

class TestDetailsScreen extends StatelessWidget {
  final TestRecord? record;

  const TestDetailsScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    if (record == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test Details')),
        body: const Center(child: Text('Record not found.')),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Result header
            _buildResultHeader(theme),
            const SizedBox(height: AppSpacing.lg),

            // Metadata card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    MetadataRow(
                        icon: Icons.tag,
                        label: 'Test ID',
                        value: record!.testId,
                        monospace: true),
                    const MetadataDivider(),
                    MetadataRow(
                        icon: Icons.person_outline,
                        label: 'Operator',
                        value: record!.operatorId),
                    const MetadataDivider(),
                    MetadataRow(
                        icon: Icons.access_time,
                        label: 'Timestamp',
                        value: record!.timestamp.toDisplayString()),
                    const MetadataDivider(),
                    MetadataRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: record!.locationString,
                      trailing: TextButton(
                        onPressed: () {
                          context.push(RouteNames.location);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const MetadataDivider(),
                    MetadataRow(
                      icon: Icons.fingerprint,
                      label: 'Image Hash',
                      value: 'SHA-256: ${record!.imageHash.substring(0, 16)}...',
                      monospace: true,
                    ),
                    const MetadataDivider(),
                    MetadataRow(
                      icon: Icons.verified_user_outlined,
                      label: 'Signature',
                      value: record!.digitalSignature,
                      trailing: Icon(
                        record!.digitalSignature == 'VALID'
                            ? Icons.check_circle
                            : Icons.pending,
                        size: 16,
                        color: record!.digitalSignature == 'VALID'
                            ? AppColors.negative
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Images
            Row(
              children: [
                Expanded(
                  child: _buildImageTile('Captured Image', Icons.camera_alt),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildImageTile('Reference Card', Icons.palette),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Verify button
            ElevatedButton.icon(
              onPressed: () {
                context.go('${RouteNames.qrVerification}?mode=generate');
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('View QR Code'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                // In a real app, this would trigger verification
                context.go('${RouteNames.qrVerification}?mode=verify');
              },
              icon: const Icon(Icons.verified),
              label: const Text('Verify Record'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader(ThemeData theme) {
    Color bgColor;
    Color fgColor;

    switch (record!.result) {
      case TestResult.positive:
        bgColor = AppColors.positive.withValues(alpha: 0.15);
        fgColor = AppColors.positive;
        break;
      case TestResult.negative:
        bgColor = AppColors.negative.withValues(alpha: 0.15);
        fgColor = AppColors.negative;
        break;
      case TestResult.inconclusive:
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        fgColor = AppColors.warning;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: fgColor.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          record!.result.label,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: fgColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildImageTile(String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2128),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Center(
            child: Icon(icon, color: Colors.white.withValues(alpha: 0.2), size: 32),
          ),
        ),
      ],
    );
  }
}
