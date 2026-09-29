import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/verification_controller.dart';
import '../../records/controllers/record_controller.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_states.dart';

class QrVerificationScreen extends StatefulWidget {
  final String mode; // 'generate' or 'verify'

  const QrVerificationScreen({super.key, required this.mode});

  @override
  State<QrVerificationScreen> createState() => _QrVerificationScreenState();
}

class _QrVerificationScreenState extends State<QrVerificationScreen> {
  final _testIdCtrl = TextEditingController();

  @override
  void dispose() {
    _testIdCtrl.dispose();
    super.dispose();
  }

  void _verifyManual() async {
    final testId = _testIdCtrl.text.trim();
    if (testId.isEmpty) return;

    final ctrl = context.read<VerificationController>();
    await ctrl.verifyById(testId);

    if (mounted) {
      if (ctrl.status == VerifyStatus.verified) {
        context.go(RouteNames.verificationSuccess);
      } else if (ctrl.status == VerifyStatus.failed) {
        context.go(RouteNames.tamperedRecord);
      }
    }
  }

  void _verifyDemo(String testId) async {
    final ctrl = context.read<VerificationController>();
    await ctrl.verifyById(testId);

    if (mounted) {
      if (ctrl.status == VerifyStatus.verified) {
        context.go(RouteNames.verificationSuccess);
      } else if (ctrl.status == VerifyStatus.failed) {
        context.go(RouteNames.tamperedRecord);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVerify = widget.mode == 'verify';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isVerify ? 'Verify Record' : 'Record QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isVerify) {
              context.go(RouteNames.dashboard);
            } else {
              context.go(RouteNames.digitalRecord);
            }
          },
        ),
      ),
      body: isVerify ? _buildVerifyMode(theme) : _buildGenerateMode(theme),
      bottomNavigationBar: isVerify ? _buildBottomNav(context) : null,
    );
  }

  Widget _buildGenerateMode(ThemeData theme) {
    final recordCtrl = context.watch<RecordController>();
    final qrData = recordCtrl.qrData;

    if (qrData == null) {
      return const Center(child: Text('No QR data available.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 250.0,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Scan to verify authenticity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyMode(ThemeData theme) {
    final ctrl = context.watch<VerificationController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR Scanner placeholder
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.qr_code_scanner, size: 80, color: Colors.white.withValues(alpha: 0.3)),
                Positioned(
                  bottom: 20,
                  child: Text(
                    'Point camera at QR code',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR', style: TextStyle(color: AppColors.textMuted)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Enter Test ID manually',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _testIdCtrl,
            decoration: const InputDecoration(
              hintText: 'e.g. TEST-2026-001',
              prefixIcon: Icon(Icons.tag),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: AppSpacing.md),
          
          if (ctrl.isVerifying)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _verifyManual,
              child: const Text('Verify'),
            ),

          if (ctrl.error != null) ...[
            const SizedBox(height: AppSpacing.md),
            ErrorState(message: ctrl.error!),
          ],

          // Demo buttons for prototype
          const SizedBox(height: AppSpacing.xxl),
          const Text('Demo Actions (Prototype Only):', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _verifyDemo('TEST-2026-001'), // Known valid
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.negative, side: const BorderSide(color: AppColors.negative)),
                  child: const Text('Simulate Valid'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _verifyDemo('TEST-2026-TAMPERED'), // Known tampered
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.positive, side: const BorderSide(color: AppColors.positive)),
                  child: const Text('Simulate Tampered'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // Verify is index 2
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Verify'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
      onTap: (index) {
        if (index == 0) context.go(RouteNames.dashboard);
        if (index == 1) context.go(RouteNames.testHistory);
        if (index == 3) {} // Profile placeholder
      },
    );
  }
}
