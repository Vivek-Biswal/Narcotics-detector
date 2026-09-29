import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/calibration_controller.dart';
import '../../result/controllers/result_controller.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../shared/widgets/app_states.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCalibration();
    });
  }

  Future<void> _startCalibration() async {
    final ctrl = context.read<CalibrationController>();
    ctrl.reset();
    // Using mock image path
    await ctrl.startCalibration('mock://captured_image.jpg');

    if (mounted && ctrl.completed && ctrl.analysisResult != null) {
      // Pass result to ResultController
      context.read<ResultController>().setFromAnalysis(ctrl.analysisResult!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CalibrationController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Calibration'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            _buildImagePreview(theme),
            const SizedBox(height: AppSpacing.lg),
            _buildProcessingCard(theme, ctrl),
            const SizedBox(height: AppSpacing.lg),
            if (ctrl.error != null)
              ErrorState(
                message: ctrl.error!,
                onRetry: _startCalibration,
              ),
            if (ctrl.completed && ctrl.error == null)
              ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.result),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View Result'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.biotech_rounded,
                    size: 48, color: Colors.white.withValues(alpha: 0.1)),
                const SizedBox(height: 8),
                Text('Captured Image Preview',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.2), fontSize: 12)),
              ],
            ),
          ),
          // Reference card overlay
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              width: 60,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 1.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text('REF',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 9,
                        letterSpacing: 1)),
              ),
            ),
          ),
          // Status chip
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.negative.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: AppColors.negative, size: 12),
                  SizedBox(width: 4),
                  Text('Card Detected',
                      style: TextStyle(
                          color: AppColors.negative, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard(ThemeData theme, CalibrationController ctrl) {
    final steps = CalibrationStep.values;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (ctrl.isProcessing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    ctrl.completed
                        ? Icons.check_circle_rounded
                        : Icons.error_rounded,
                    color: ctrl.completed
                        ? AppColors.negative
                        : AppColors.positive,
                    size: 20,
                  ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  ctrl.isProcessing
                      ? 'Processing...'
                      : ctrl.completed
                          ? 'Analysis Complete'
                          : 'Processing Failed',
                  style: theme.textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  '${(ctrl.progress * 100).toInt()}%',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: ctrl.progress,
                minHeight: 6,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Step list
            ...steps.map((step) {
              final stepIndex = steps.indexOf(step);
              final currentIndex = ctrl.currentStep != null
                  ? steps.indexOf(ctrl.currentStep!)
                  : -1;

              bool isDone = ctrl.completed ||
                  (currentIndex > stepIndex);
              bool isCurrent =
                  !ctrl.completed && currentIndex == stepIndex;

              return _StepRow(
                label: step.label,
                isDone: isDone,
                isCurrent: isCurrent,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;

  const _StepRow({
    required this.label,
    required this.isDone,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;

    if (isDone) {
      color = AppColors.negative;
      icon = Icons.check_circle_rounded;
    } else if (isCurrent) {
      color = AppColors.primary;
      icon = Icons.radio_button_checked;
    } else {
      color = AppColors.textMuted;
      icon = Icons.radio_button_unchecked;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (isCurrent)
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isCurrent || isDone ? null : AppColors.textMuted,
              fontWeight:
                  isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
