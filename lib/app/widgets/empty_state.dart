import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tampilan saat data kosong atau terjadi error (dengan tombol coba lagi).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isError;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.isError = false,
  });

  factory EmptyState.error(String message, VoidCallback onRetry) => EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Gagal memuat data',
        message: message,
        actionLabel: 'Coba Lagi',
        onAction: onRetry,
        isError: true,
      );

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.tealLight;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: color),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(isError ? Icons.refresh_rounded : Icons.arrow_forward_rounded),
                  label: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
