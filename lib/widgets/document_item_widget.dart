import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../utils/theme.dart';

class DocumentItemWidget extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback onUpload;
  final int index;

  const DocumentItemWidget({
    super.key,
    required this.document,
    required this.onUpload,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _borderColor,
          width: document.isUploaded ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Document icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconData, color: _iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  document.description,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                if (document.fileName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.attach_file, size: 12, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          document.fileName!,
                          style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Status / Upload button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildStatusChip(),
              if (!document.isUploaded) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onUpload,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.upload, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Upload',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    Color bg;
    String label;

    switch (document.status) {
      case DocumentStatus.verified:
        color = AppTheme.success;
        bg = AppTheme.success.withOpacity(0.1);
        label = '✓ Verified';
        break;
      case DocumentStatus.uploaded:
        color = AppTheme.primary;
        bg = AppTheme.primarySurface;
        label = '⬆ Uploaded';
        break;
      case DocumentStatus.rejected:
        color = AppTheme.error;
        bg = AppTheme.error.withOpacity(0.1);
        label = '✕ Rejected';
        break;
      case DocumentStatus.missing:
        color = AppTheme.textLight;
        bg = AppTheme.surface;
        label = 'Missing';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Color get _borderColor {
    switch (document.status) {
      case DocumentStatus.verified:
        return AppTheme.success.withOpacity(0.3);
      case DocumentStatus.uploaded:
        return AppTheme.primary.withOpacity(0.3);
      case DocumentStatus.rejected:
        return AppTheme.error.withOpacity(0.3);
      default:
        return AppTheme.border;
    }
  }

  Color get _iconBg {
    switch (document.status) {
      case DocumentStatus.verified:
        return AppTheme.success.withOpacity(0.1);
      case DocumentStatus.uploaded:
        return AppTheme.primarySurface;
      case DocumentStatus.rejected:
        return AppTheme.error.withOpacity(0.1);
      default:
        return AppTheme.surface;
    }
  }

  Color get _iconColor {
    switch (document.status) {
      case DocumentStatus.verified:
        return AppTheme.success;
      case DocumentStatus.uploaded:
        return AppTheme.primary;
      case DocumentStatus.rejected:
        return AppTheme.error;
      default:
        return AppTheme.textLight;
    }
  }

  IconData get _iconData {
    switch (document.status) {
      case DocumentStatus.verified:
        return Icons.verified_outlined;
      case DocumentStatus.uploaded:
        return Icons.description_outlined;
      case DocumentStatus.rejected:
        return Icons.error_outline;
      default:
        return Icons.upload_file_outlined;
    }
  }
}
