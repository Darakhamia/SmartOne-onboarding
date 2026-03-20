import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/onboarding_provider.dart';
import '../models/document_model.dart';
import '../utils/theme.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _ibanCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _mapsCtrl = TextEditingController();

  bool get _showMapsField => _websiteCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _websiteCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ibanCtrl.dispose();
    _websiteCtrl.dispose();
    _mapsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (ctx, provider, _) {
        final uploaded = provider.uploadedDocumentsCount;
        final total = provider.totalDocumentsCount;
        final allDone = uploaded == total;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F7F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('Documents',
                style: TextStyle(fontWeight: FontWeight.w700)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // ── Progress header ─────────────────────────────────────────
              _ProgressHeader(uploaded: uploaded, total: total, allDone: allDone),
              const SizedBox(height: 16),

              // ── Bank Details ────────────────────────────────────────────
              _SectionCard(
                title: 'Bank Details',
                icon: Icons.account_balance_rounded,
                iconColor: AppTheme.primary,
                child: _DocField(
                  label: 'IBAN',
                  hint: 'e.g. GB29 NWBK 6016 1331 9268 19',
                  controller: _ibanCtrl,
                  keyboardType: TextInputType.text,
                  prefix: Icons.credit_card_rounded,
                ),
              ),
              const SizedBox(height: 12),

              // ── Business Presence ───────────────────────────────────────
              _SectionCard(
                title: 'Business Presence',
                icon: Icons.language_rounded,
                iconColor: AppTheme.accent,
                child: Column(
                  children: [
                    _DocField(
                      label: 'Website URL',
                      hint: 'https://yourcompany.com',
                      controller: _websiteCtrl,
                      keyboardType: TextInputType.url,
                      prefix: Icons.link_rounded,
                    ),
                    // Conditional Google Maps URL
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: _showMapsField
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _DocField(
                                label: 'Google Maps URL',
                                hint: 'https://maps.google.com/?q=...',
                                controller: _mapsCtrl,
                                keyboardType: TextInputType.url,
                                prefix: Icons.location_on_rounded,
                                prefixColor: const Color(0xFFEA4335),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (!_showMapsField)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 13, color: AppTheme.textLight),
                            const SizedBox(width: 6),
                            Text(
                              'Add website URL to unlock Google Maps field',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textLight.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Section label ───────────────────────────────────────────
              Row(
                children: [
                  const Text('Required Documents',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  Text('$uploaded / $total',
                      style: TextStyle(
                          fontSize: 13,
                          color: allDone ? AppTheme.success : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'PDF or image format. Must be current and legible.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),

              // ── Document cards ──────────────────────────────────────────
              ...provider.documents.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DocCard(
                    document: entry.value,
                    onTap: () => _upload(context, provider, entry.key),
                  ),
                );
              }),

              if (allDone) ...[
                const SizedBox(height: 8),
                _AllDoneBanner(),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _upload(BuildContext ctx, OnboardingProvider provider, int i) async {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const _UploadingDialog(),
    );
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!ctx.mounted) return;
    Navigator.pop(ctx);

    const names = [
      'certificate_incorporation.pdf',
      'company_registry_extract.pdf',
      'ubo_declaration.pdf',
      'director_passport.jpg',
      'proof_of_address.pdf',
      'bank_account_confirmation.pdf',
    ];
    provider.uploadDocument(i, names[i]);

    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 17),
        SizedBox(width: 10),
        Text('Document uploaded'),
      ]),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final int uploaded;
  final int total;
  final bool allDone;
  const _ProgressHeader({required this.uploaded, required this.total, required this.allDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allDone
              ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
              : [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  allDone ? Icons.check_rounded : Icons.folder_open_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allDone ? 'All documents uploaded!' : 'Compliance Documents',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      allDone
                          ? 'Under review — we\'ll notify you'
                          : '$uploaded of $total documents uploaded',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Text(
                '$uploaded/$total',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? uploaded / total : 0,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DocField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? prefix;
  final Color? prefixColor;
  const _DocField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.prefixColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF7F7F8),
            prefixIcon: prefix != null
                ? Icon(prefix, size: 17,
                    color: prefixColor ?? AppTheme.textSecondary)
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            hintStyle: const TextStyle(
                fontSize: 13, color: AppTheme.textLight),
          ),
        ),
      ],
    );
  }
}

class _DocCard extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback onTap;
  const _DocCard({required this.document, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUploaded = document.isUploaded;
    final isVerified = document.status == DocumentStatus.verified;
    final isRejected = document.status == DocumentStatus.rejected;

    Color statusColor = AppTheme.textLight;
    IconData statusIcon = Icons.upload_file_rounded;
    String statusLabel = 'Upload';

    if (isVerified) {
      statusColor = AppTheme.success;
      statusIcon = Icons.verified_rounded;
      statusLabel = 'Verified';
    } else if (isRejected) {
      statusColor = AppTheme.error;
      statusIcon = Icons.cancel_rounded;
      statusLabel = 'Rejected';
    } else if (isUploaded) {
      statusColor = AppTheme.warning;
      statusIcon = Icons.hourglass_empty_rounded;
      statusLabel = 'Pending';
    }

    return GestureDetector(
      onTap: (isVerified) ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isVerified
                ? AppTheme.success.withOpacity(0.3)
                : isRejected
                    ? AppTheme.error.withOpacity(0.3)
                    : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVerified
                    ? Icons.insert_drive_file_rounded
                    : Icons.insert_drive_file_outlined,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(document.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(document.description,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(statusLabel,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllDoneBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.success.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('All documents submitted',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success)),
                SizedBox(height: 2),
                Text('Your documents are under review.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadingDialog extends StatelessWidget {
  const _UploadingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
            SizedBox(height: 20),
            Text('Uploading…',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Please wait',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
