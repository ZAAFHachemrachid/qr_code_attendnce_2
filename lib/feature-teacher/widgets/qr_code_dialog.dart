import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';

class QRCodeDialog extends StatelessWidget {
  final String qrData;
  final DateTime expiry;
  final VoidCallback onRegenerateQR;

  const QRCodeDialog({
    super.key,
    required this.qrData,
    required this.expiry,
    required this.onRegenerateQR,
  });

  String _getTimeLeft() {
    final now = DateTime.now();
    if (now.isAfter(expiry)) {
      return 'Expired';
    }

    final difference = expiry.difference(now);
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Attendance QR Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.emeraldPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.emeraldPrimary.withOpacity(0.2),
                ),
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.emeraldPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Time Remaining: ${_getTimeLeft()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: 'Regenerate',
                  onPressed: onRegenerateQR,
                  variant: CustomButtonVariant.outlined,
                  icon: Icons.refresh,
                ),
                CustomButton(
                  text: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: CustomButtonVariant.secondary,
                  icon: Icons.close,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
