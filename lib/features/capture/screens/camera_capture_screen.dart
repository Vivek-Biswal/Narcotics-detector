import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/capture_controller.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/enums/app_enums.dart';
import '../../../shared/widgets/app_states.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaptureController>().initialize();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CaptureController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture Test Image'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.dashboard),
        ),
      ),
      body: _buildBody(ctrl),
    );
  }

  Widget _buildBody(CaptureController ctrl) {
    if (ctrl.state == CaptureState.captured &&
        ctrl.capturedImagePath != null) {
      return _buildPreviewConfirm(ctrl);
    }
    return _buildCameraView(ctrl);
  }

  Widget _buildCameraView(CaptureController ctrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Mock camera preview
        _MockCameraPreview(pulseAnim: _pulseAnim),

        // Capture guide overlay
        _CaptureGuideOverlay(),

        // Warnings
        if (ctrl.state == CaptureState.cardNotDetected)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: WarningBanner(
              message: 'Reference card not detected — ensure the colour card is within the frame.',
            ),
          ),
        if (ctrl.state == CaptureState.qualityWarning)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: WarningBanner(
              message: 'Image quality too low — ensure adequate lighting and hold steady.',
            ),
          ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _CaptureControls(
            ctrl: ctrl,
            onCapture: () async {
              await ctrl.capture();
              if (ctrl.state == CaptureState.captured && mounted) {
                // Proceed automatically to detection
              }
            },
          ),
        ),

        // GPS indicator
        Positioned(
          top: 16,
          right: 16,
          child: _GpsIndicator(
            lat: ctrl.latitude,
            lng: ctrl.longitude,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewConfirm(CaptureController ctrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Captured image (mock placeholder)
        Container(
          color: const Color(0xFF1A1A2E),
          child: const Center(
            child: _MockCapturedImage(),
          ),
        ),

        // Bottom confirm/retake
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.negative.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.negative, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Image captured successfully',
                        style: TextStyle(
                          color: AppColors.negative,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: ctrl.retake,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ctrl.confirmCapture();
                          context.go(RouteNames.referenceDetection);
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Confirm & Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MockCameraPreview extends StatelessWidget {
  final Animation<double> pulseAnim;

  const _MockCameraPreview({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A1A),
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (context, child) {
          return CustomPaint(
            painter: _CameraGridPainter(opacity: pulseAnim.value * 0.15),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: Colors.white.withOpacity(0.2),
                size: 64,
              ),
              const SizedBox(height: 12),
              Text(
                'CAMERA PREVIEW',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.2),
                  letterSpacing: 3,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Mock implementation',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.1),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureGuideOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GuideOverlayPainter(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 40, vertical: 120),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Place test kit inside the frame · Include colour reference card',
                style: TextStyle(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.5), width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.accent.withOpacity(0.05),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.palette_outlined,
                      color: AppColors.accent, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'REFERENCE CARD ZONE',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}

class _CaptureControls extends StatelessWidget {
  final CaptureController ctrl;
  final VoidCallback onCapture;

  const _CaptureControls({required this.ctrl, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.9),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flash toggle placeholder
          IconButton(
            icon: const Icon(Icons.flash_off, color: Colors.white70),
            onPressed: () {},
            tooltip: 'Flash',
          ),

          // Capture button
          GestureDetector(
            onTap: ctrl.state == CaptureState.idle ? null : onCapture,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  color: ctrl.state == CaptureState.idle
                      ? Colors.white38
                      : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ctrl.state == CaptureState.idle
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black54),
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // Flip camera placeholder
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined,
                color: Colors.white70),
            onPressed: () {},
            tooltip: 'Flip camera',
          ),
        ],
      ),
    );
  }
}

class _GpsIndicator extends StatelessWidget {
  final double? lat;
  final double? lng;

  const _GpsIndicator({this.lat, this.lng});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            lat != null ? Icons.gps_fixed : Icons.gps_not_fixed,
            size: 12,
            color: lat != null ? AppColors.negative : Colors.orange,
          ),
          const SizedBox(width: 5),
          Text(
            lat != null
                ? '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}'
                : 'Locating...',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MockCapturedImage extends StatelessWidget {
  const _MockCapturedImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Simulated test kit background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.biotech_rounded,
                    size: 64, color: Colors.white.withOpacity(0.15)),
                const SizedBox(height: 8),
                Text(
                  'TEST KIT IMAGE',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.2),
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Reference card indicator
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.accent.withOpacity(0.7), width: 2),
                borderRadius: BorderRadius.circular(4),
                color: AppColors.accent.withOpacity(0.05),
              ),
              child: Center(
                child: Text(
                  'REF\nCARD',
                  style: TextStyle(
                    color: AppColors.accent.withOpacity(0.7),
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  final double opacity;
  _CameraGridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..strokeWidth = 0.5;

    // Rule of thirds grid
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(size.width * i / 3, 0),
        Offset(size.width * i / 3, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 3),
        Offset(size.width, size.height * i / 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CameraGridPainter old) => old.opacity != opacity;
}

class _GuideOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.5);
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    // Dim entire screen
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), dimPaint);

    // Clear center rectangle for capture area
    const margin = 40.0;
    const topOffset = 100.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, topOffset, size.width - margin * 2,
            size.height - topOffset - 200),
        const Radius.circular(12),
      ),
      clearPaint,
    );
    canvas.restore();

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const bSize = 24.0;
    final left = margin;
    final right = size.width - margin;
    final top = topOffset;
    final bottom = size.height - 200;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(left, top + bSize)
          ..lineTo(left, top)
          ..lineTo(left + bSize, top),
        bracketPaint);
    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(right - bSize, top)
          ..lineTo(right, top)
          ..lineTo(right, top + bSize),
        bracketPaint);
    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(left, bottom - bSize)
          ..lineTo(left, bottom)
          ..lineTo(left + bSize, bottom),
        bracketPaint);
    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(right - bSize, bottom)
          ..lineTo(right, bottom)
          ..lineTo(right, bottom - bSize),
        bracketPaint);
  }

  @override
  bool shouldRepaint(_GuideOverlayPainter _) => false;
}
