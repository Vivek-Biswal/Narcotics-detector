import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/record_controller.dart';
import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions/extensions.dart';
import '../../../shared/widgets/status_badges.dart';
import '../../../shared/widgets/metadata_row.dart';
import '../../../shared/widgets/app_states.dart';

class DigitalRecordScreen extends StatefulWidget {
  const DigitalRecordScreen({super.key});

  @override
  State<DigitalRecordScreen> createState() => _DigitalRecordScreenState();
}

class _DigitalRecordScreenState extends State<DigitalRecordScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-save on entry if not yet saved
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<RecordController>();
      if (ctrl.status == RecordStatus.idle && ctrl.currentRecord != null) {
        ctrl.saveRecord();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RecordController>();
    final record = ctrl.currentRecord;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.result),
        ),
        actions: [
          if (record != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _shareRecord(record.testId),
              tooltip: 'Share Record',
            ),
        ],
      ),
      body: record == null
          ? const AppLoadingState(message: 'Preparing record...')
          : _buildBody(theme, ctrl),
    );
  }

  Widget _buildBody(ThemeData theme, RecordController ctrl) {
    final record = ctrl.currentRecord!;
    final isSaving = ctrl.status == RecordStatus.saving;
    final isSaved = ctrl.status == RecordStatus.saved;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          // Record header
          _RecordHeader(record: record, isSaving: isSaving),
          const SizedBox(height: AppSpacing.md),

          // Image thumbnail + hash
          _ImageSection(record: record),
          const SizedBox(height: AppSpacing.md),

          // Full metadata
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const SectionHeader(title: 'Record Details'),
                  MetadataRow(
                      icon: Icons.tag,
                      label: 'Test ID',
                      value: record.testId,
                      monospace: true),
                  const MetadataDivider(),
                  MetadataRow(
                      icon: Icons.person_outline,
                      label: 'Operator',
                      value: record.operatorId),
                  const MetadataDivider(),
                  MetadataRow(
                      icon: Icons.access_time,
                      label: 'Timestamp',
                      value: record.timestamp.toDisplayString()),
                  const MetadataDivider(),
                  MetadataRow(
                      icon: Icons.location_on_outlined,
                      label: 'GPS',
                      value: record.locationString),
                  const MetadataDivider(),
                  MetadataRow(
                    icon: Icons.fingerprint,
                    label: 'Image Hash',
                    value:
                        'SHA-256: ${record.imageHash.substring(0, 16)}...',
                    monospace: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: record.imageHash));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Hash copied to clipboard')),
                        );
                      },
                      tooltip: 'Copy hash',
                    ),
                  ),
                  const MetadataDivider(),
                  MetadataRow(
                    icon: Icons.verified_user_outlined,
                    label: 'Signature',
                    value: record.digitalSignature,
                    trailing: Icon(
                      record.digitalSignature == 'VALID'
                          ? Icons.check_circle
                          : Icons.pending,
                      size: 16,
                      color: record.digitalSignature == 'VALID'
                          ? AppColors.negative
                          : AppColors.warning,
                    ),
                  ),
                  const MetadataDivider(),
                  Row(
                    children: [
                      const SizedBox(width: 24),
                      Text('Status',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted)),
                      const SizedBox(width: 16),
                      const Spacer(),
                      VerificationBadge(status: record.verificationStatus),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Saving status
          if (isSaving) ...[
            const InlineLoader(label: 'Saving and signing record...'),
            const SizedBox(height: AppSpacing.md),
          ],

          if (ctrl.error != null) ...[
            ErrorState(
                message: ctrl.error!, onRetry: () => ctrl.saveRecord()),
            const SizedBox(height: AppSpacing.md),
          ],

          // Action buttons
          ElevatedButton.icon(
            onPressed: isSaving
                ? null
                : () => context.go(
                    '${RouteNames.qrVerification}?mode=generate'),
            icon: const Icon(Icons.qr_code_rounded),
            label: const Text('Generate QR Code'),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving
                      ? null
                      : () => context.go(
                          '${RouteNames.qrVerification}?mode=verify'),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Verify'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : _saveToDevice,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _shareRecord(String testId) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share: $testId (TODO)')),
    );
  }

  void _saveToDevice() {
    // TODO: Save PDF / JSON to device storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Record saved locally (TODO: PDF export)')),
    );
  }
}

class _RecordHeader extends StatelessWidget {
  final dynamic record;
  final bool isSaving;

  const _RecordHeader({required this.record, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.testId,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 4),
              ResultBadge(result: record.result),
            ],
          ),
        ),
        if (isSaving)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          VerificationBadge(status: record.verificationStatus),
      ],
    );
  }
}

class _ImageSection extends StatelessWidget {
  final dynamic record;

  const _ImageSection({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Image thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1C2128),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Icon(Icons.biotech_rounded,
                  color: AppColors.primary.withOpacity(0.3), size: 36),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Captured Image',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  HashChip(hash: record.imageHash),
                  const SizedBox(height: 6),
                  Text(
                    '// TODO: Display real captured image',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
