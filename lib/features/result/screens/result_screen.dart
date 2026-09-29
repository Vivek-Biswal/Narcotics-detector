import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/result_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../records/controllers/record_controller.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../core/extensions/extensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/status_badges.dart';
import '../../../shared/widgets/metadata_row.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resultCtrl = context.watch<ResultController>();
    final auth = context.watch<AuthController>();

    // Fallback to mock if navigated directly
    final result = resultCtrl.result ?? TestResult.positive;
    final confidence = resultCtrl.confidence ?? 0.92;
    final substanceName =
        resultCtrl.substanceName ?? 'Heroin Class A (presumptive)';
    final colourDelta = resultCtrl.colourDelta ?? 'ΔE = 42.3';
    final operator = auth.operator;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final testId =
        'TEST-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.dashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Disclaimer banner
            _DisclaimerBanner(),
            const SizedBox(height: AppSpacing.lg),

            // Result hero card
            _ResultHeroCard(result: result),
            const SizedBox(height: AppSpacing.lg),

            // Analysis info
            _AnalysisCard(
              result: result,
              confidence: confidence,
              substanceName: substanceName,
              colourDelta: colourDelta,
            ),
            const SizedBox(height: AppSpacing.md),

            // Test metadata
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    const SectionHeader(title: 'Test Metadata'),
                    MetadataRow(
                        icon: Icons.tag,
                        label: 'Test ID',
                        value: testId,
                        monospace: true),
                    const MetadataDivider(),
                    MetadataRow(
                        icon: Icons.access_time,
                        label: 'Timestamp',
                        value: now.toDisplayString()),
                    const MetadataDivider(),
                    MetadataRow(
                        icon: Icons.person_outline,
                        label: 'Operator',
                        value: operator?.id ?? 'OP-1042'),
                    const MetadataDivider(),
                    MetadataRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value:
                            '${resultCtrl.latitude?.toStringAsFixed(4) ?? '28.4595'}, ${resultCtrl.longitude?.toStringAsFixed(4) ?? '77.0266'}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            ElevatedButton.icon(
              onPressed: () {
                // Store result and navigate to digital record
                context.read<RecordController>().prepareNewRecord(
                  result: result,
                  operatorId: operator?.id ?? 'OP-1042',
                  testId: testId,
                  latitude: resultCtrl.latitude ?? 28.4595,
                  longitude: resultCtrl.longitude ?? 77.0266,
                  imagePath: 'mock://captured_image.jpg',
                  confidence: confidence,
                  substanceName: substanceName,
                );
                context.go(RouteNames.digitalRecord);
              },
              icon: const Icon(Icons.save_alt_rounded),
              label: const Text('Create Digital Record'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => context.go(RouteNames.cameraCapture),
              icon: const Icon(Icons.refresh),
              label: const Text('Retake Test'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: AppColors.warning, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.presumptiveLabel,
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.resultDisclaimer,
                  style: TextStyle(
                    color: AppColors.warning.withOpacity(0.8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeroCard extends StatelessWidget {
  final TestResult result;

  const _ResultHeroCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(result);
    final color = config['color'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4), width: 2),
            ),
            child: Icon(
              config['icon'] as IconData,
              color: color,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            result.label,
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            result.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> _getConfig(TestResult result) {
    switch (result) {
      case TestResult.positive:
        return {'color': AppColors.positive, 'icon': Icons.warning_rounded};
      case TestResult.negative:
        return {
          'color': AppColors.negative,
          'icon': Icons.check_circle_rounded
        };
      case TestResult.inconclusive:
        return {'color': AppColors.inconclusive, 'icon': Icons.help_rounded};
    }
  }
}

class _AnalysisCard extends StatelessWidget {
  final TestResult result;
  final double confidence;
  final String substanceName;
  final String colourDelta;

  const _AnalysisCard({
    required this.result,
    required this.confidence,
    required this.substanceName,
    required this.colourDelta,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePct = (confidence * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Analysis Details'),
            const SizedBox(height: AppSpacing.sm),

            // Confidence meter
            Row(
              children: [
                Text('Confidence', style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(
                  '$confidencePct%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: confidencePct >= 80
                        ? AppColors.negative
                        : AppColors.inconclusive,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 8,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  confidence >= 0.8
                      ? AppColors.negative
                      : AppColors.inconclusive,
                ),
              ),
            ),
            const MetadataDivider(),

            if (result == TestResult.positive) ...[
              MetadataRow(
                icon: Icons.science_outlined,
                label: 'Substance',
                value: substanceName,
              ),
              const MetadataDivider(),
            ],

            MetadataRow(
              icon: Icons.palette_outlined,
              label: 'Colour Delta',
              value: colourDelta,
            ),
            const MetadataDivider(),
            MetadataRow(
              icon: Icons.check_circle_outlined,
              label: 'Card Status',
              value: 'Detected · Calibration OK',
            ),
          ],
        ),
      ),
    );
  }
}
