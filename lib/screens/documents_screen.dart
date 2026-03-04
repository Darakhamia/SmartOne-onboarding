import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../utils/theme.dart';
import '../widgets/document_item_widget.dart';
import '../widgets/section_header.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        final uploaded = provider.uploadedDocumentsCount;
        final total = provider.totalDocumentsCount;
        final allDone = uploaded == total;

        return Scaffold(
          backgroundColor: AppTheme.white,
          appBar: AppBar(
            title: const Text('Documents'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: allDone
                      ? const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (allDone ? AppTheme.success : AppTheme.primary).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_outlined, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Compliance Documents',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                allDone ? 'All documents uploaded!' : '$uploaded of $total documents uploaded',
                                style: const TextStyle(fontSize: 13, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: Center(
                            child: Text(
                              '$uploaded/$total',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total > 0 ? uploaded / total : 0,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppTheme.warning),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All documents must be clear, valid, and in PDF or image format. Expired documents will be rejected.',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: 'Required Documents',
                subtitle: 'Upload all 6 required compliance documents',
                trailing: allDone
                    ? const Icon(Icons.check_circle, color: AppTheme.success, size: 20)
                    : null,
              ),
              ...provider.documents.asMap().entries.map((entry) {
                return DocumentItemWidget(
                  document: entry.value,
                  index: entry.key,
                  onUpload: () => _simulateUpload(context, provider, entry.key),
                );
              }),
              if (allDone) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.success.withOpacity(0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: AppTheme.success, size: 24),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All documents submitted',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.success),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Your documents are under review. You will be notified once verified.',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _simulateUpload(
    BuildContext context,
    OnboardingProvider provider,
    int index,
  ) async {
    // Show uploading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 20),
            Text('Uploading document...', style: TextStyle(fontSize: 14)),
            SizedBox(height: 8),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!context.mounted) return;
    Navigator.pop(context);

    final docNames = [
      'certificate_incorporation.pdf',
      'company_registry_extract.pdf',
      'ubo_declaration.pdf',
      'director_passport.jpg',
      'proof_of_address.pdf',
      'bank_account_confirmation.pdf',
    ];

    provider.uploadDocument(index, docNames[index]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Document uploaded successfully'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
