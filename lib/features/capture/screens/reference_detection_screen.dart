import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../shared/widgets/app_states.dart';

class ReferenceDetectionScreen extends StatefulWidget {
  const ReferenceDetectionScreen({super.key});

  @override
  State<ReferenceDetectionScreen> createState() =>
      _ReferenceDetectionScreenState();
}

class _ReferenceDetectionScreenState extends State<ReferenceDetectionScreen> {
  DetectionState _detectionState = DetectionState.detecting;
  bool _analysing = false;

  @override
  void initState() {
    super.initState();
    _runDetection();
  }

  Future<void> _runDetection() async {
    setState(() {
      _detectionState = DetectionState.detecting;
      _analysing = true;
    });
    // Simulate detection delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _detectionState = DetectionState.detected;
        _analysing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Reference Card Detection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.cameraCapture),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildImageArea()),
          _buildStatusPanel(theme),
        ],
      ),
    );
  }

  Widget _buildImageArea() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Captured image mock
        Container(
          color: const Color(0xFF0D1117),
          child: Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _getBorderColor().withValues(alpha: 0.6), width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.biotech_rounded,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.1)),
                        const SizedBox(height: 8),
                        Text(
                          'CAPTURED IMAGE',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.15),
                            letterSpacing: 2,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reference card detection box
                  if (_detectionState == DetectionState.detected)
                    Positioned(
                      bottom: 30,
                      left: 30,
                      child: _DetectionBox(),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Scanning animation overlay
        if (_analysing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ScanningBar(),
          ),
      ],
    );
  }

  Color _getBorderColor() {
    switch (_detectionState) {
      case DetectionState.detected:
        return AppColors.negative;
      case DetectionState.notDetected:
        return AppColors.positive;
      case DetectionState.poorLighting:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildStatusPanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDetectionStatus(theme),
          const SizedBox(height: AppSpacing.md),
          if (_detectionState == DetectionState.detecting)
            const InlineLoader(label: 'Scanning for reference card...')
          else ...[
            _buildDetectionDetails(theme),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(RouteNames.cameraCapture),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _detectionState == DetectionState.detected
                        ? () => context.go(RouteNames.calibration)
                        : null,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildDetectionStatus(ThemeData theme) {
    final configs = {
      DetectionState.detecting: {
        'icon': Icons.radar,
        'color': AppColors.primary,
        'title': 'Detecting Reference Card...',
        'sub': 'Please wait while we analyse the image.',
      },
      DetectionState.detected: {
        'icon': Icons.check_circle_rounded,
        'color': AppColors.negative,
        'title': 'Reference Card Detected',
        'sub': 'Card boundary confirmed · Confidence: 94%',
      },
      DetectionState.notDetected: {
        'icon': Icons.cancel_rounded,
        'color': AppColors.positive,
        'title': 'Reference Card Not Detected',
        'sub': 'Ensure the colour reference card is visible in the image.',
      },
      DetectionState.poorLighting: {
        'icon': Icons.wb_sunny_outlined,
        'color': AppColors.warning,
        'title': 'Poor Lighting Detected',
        'sub': 'Move to a brighter environment and retake.',
      },
      DetectionState.invalidImage: {
        'icon': Icons.broken_image_outlined,
        'color': AppColors.positive,
        'title': 'Invalid Image',
        'sub': 'Image cannot be processed. Please retake.',
      },
    };

    final c = configs[_detectionState]!;
    final color = c['color'] as Color;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(c['icon'] as IconData, color: color, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c['title'] as String,
                  style: theme.textTheme.titleSmall),
              const SizedBox(height: 3),
              Text(c['sub'] as String, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionDetails(ThemeData theme) {
    if (_detectionState != DetectionState.detected) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.negative.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.negative.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _DetailRow(
              icon: Icons.check, label: 'Card bounds', value: 'x:40, y:120, w:200, h:120'),
          _DetailRow(
              icon: Icons.check, label: 'Lighting', value: 'Adequate'),
          _DetailRow(
              icon: Icons.check,
              label: 'Card orientation',
              value: 'Correct'),
          _DetailRow(
              icon: Icons.check, label: 'Image quality', value: 'Good'),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.negative),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _DetectionBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.negative, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 4,
            child: Text(
              'REF CARD',
              style: const TextStyle(
                color: AppColors.negative,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Color swatches simulation
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.purple,
              ].map((c) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                    ),
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanningBar extends StatefulWidget {
  @override
  State<_ScanningBar> createState() => _ScanningBarState();
}

class _ScanningBarState extends State<_ScanningBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return SizedBox(
          height: 400,
          child: Align(
            alignment: Alignment(0, _anim.value * 2 - 1),
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.accent.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
