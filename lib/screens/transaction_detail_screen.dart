import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../utils/theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  void _copyId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: transaction.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: ${transaction.id}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final df = DateFormat('EEEE, dd MMMM yyyy');
    final tf = DateFormat('HH:mm:ss');

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        title: Text(t.id,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary)),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copy ID',
            onPressed: () => _copyId(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero amount card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _headerColor(t),
                    _headerColor(t).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Type icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(t.typeIcon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.formattedAmount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Badge(label: t.type, light: true),
                      const SizedBox(width: 8),
                      _Badge(label: t.status, light: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    df.format(t.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    tf.format(t.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details card
            _DetailCard(
              title: 'Transaction Details',
              rows: [
                _DetailRow(label: 'Transaction ID', value: t.id, copy: true),
                _DetailRow(label: 'Description', value: t.description),
                _DetailRow(label: 'Type', value: t.type),
                _DetailRow(label: 'Status', value: t.status),
                _DetailRow(label: 'Amount',
                    value:
                        '${t.amount.toStringAsFixed(2)} ${t.currency}'),
                _DetailRow(label: 'Currency', value: t.currency),
              ],
            ),
            const SizedBox(height: 12),

            _DetailCard(
              title: 'Terminal & Location',
              rows: [
                _DetailRow(label: 'Outlet', value: t.outlet),
                _DetailRow(label: 'Terminal ID', value: t.terminalId),
                _DetailRow(label: 'Card (last 4)', value: '•••• ${t.cardLast4}'),
                _DetailRow(label: 'Merchant ID', value: t.merchantId),
              ],
            ),
            const SizedBox(height: 12),

            _DetailCard(
              title: 'Timestamps',
              rows: [
                _DetailRow(
                    label: 'Date',
                    value: DateFormat('dd/MM/yyyy').format(t.createdAt)),
                _DetailRow(
                    label: 'Time',
                    value: DateFormat('HH:mm:ss').format(t.createdAt)),
                _DetailRow(
                    label: 'Timezone', value: 'UTC'),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _headerColor(Transaction t) {
    if (t.isDeclined) return AppTheme.error;
    if (t.type == 'REFUND') return AppTheme.warning;
    if (t.type == 'VOID') return AppTheme.textSecondary;
    return AppTheme.primary;
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailRow> rows;
  const _DetailCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.3)),
          ),
          const SizedBox(height: 8),
          ...rows.asMap().entries.map((e) {
            final isLast = e.key == rows.length - 1;
            return Column(
              children: [
                e.value,
                if (!isLast)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copy;
  const _DetailRow({required this.label, required this.value, this.copy = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
              textAlign: TextAlign.right,
            ),
          ),
          if (copy) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Icon(Icons.copy_rounded,
                  size: 14, color: AppTheme.textLight),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool light;
  const _Badge({required this.label, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: light ? Colors.white.withOpacity(0.2) : AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(20),
        border: light
            ? Border.all(color: Colors.white.withOpacity(0.4))
            : Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: light ? Colors.white : AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
