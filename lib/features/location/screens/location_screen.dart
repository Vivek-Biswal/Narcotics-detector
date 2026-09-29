import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Mock Map Background
                Container(
                  color: const Color(0xFFE5E9EC),
                  child: CustomPaint(painter: _MockMapPainter()),
                ),
                
                // Pin
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 48, color: AppColors.positive),
                      SizedBox(height: 48), // Offset to put pin point in center
                    ],
                  ),
                ),
                
                // Location Details Card
                Positioned(
                  bottom: AppSpacing.lg,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.gps_fixed, color: AppColors.primary, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '28.4595, 77.0266',
                                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.black87),
                                  ),
                                  Text(
                                    'Accuracy: ±5 m',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.map),
                            label: const Text('View on Map'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
      
    // Draw some fake roads
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.6, size.height), paint);
    
    // Draw a park
    final parkPaint = Paint()..color = const Color(0xFFC8E6C9)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.6, size.height * 0.4, 150, 200), parkPaint);
    
    // Draw a river
    final waterPaint = Paint()..color = const Color(0xFFB3E5FC)..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.8)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.7, size.width, size.height * 0.9)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      waterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
