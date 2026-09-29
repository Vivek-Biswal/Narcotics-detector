import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/verification_controller.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = context.watch<VerificationController>();
    final result = ctrl.result;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text('Record Verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ctrl.reset();
            context.go(RouteNames.dashboard);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Success Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.negative,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.negative.withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 48),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Record Authenticity',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.black54),
                  ),
                  Text(
                    'VALID',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: AppColors.negative,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Checks
                  _CheckRow(label: 'Image hash matches', isValid: result?.imageHashMatches ?? true),
                  _CheckRow(label: 'Digital signature valid', isValid: result?.signatureValid ?? true),
                  _CheckRow(label: 'Timestamp valid', isValid: result?.timestampValid ?? true),
                  _CheckRow(label: 'Location valid', isValid: result?.locationValid ?? true),
                  _CheckRow(label: 'Operator valid', isValid: result?.operatorValid ?? true),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Record Details Card
            if (result?.testId != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Record Details', style: theme.textTheme.titleSmall?.copyWith(color: Colors.black87)),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Test ID', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                        Text(result!.testId!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87, fontFamily: 'monospace')),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54)),
                        const Text('Verified Authentic', style: TextStyle(color: AppColors.negative, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () {
                ctrl.reset();
                context.go(RouteNames.dashboard);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool isValid;

  const _CheckRow({required this.label, required this.isValid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? AppColors.negative : AppColors.positive,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
