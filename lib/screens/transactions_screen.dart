import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<Transaction>> _future;
  String _filter = 'ALL';
  String _search = '';
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchOpen = false;

  static const _filters = ['ALL', 'SALE', 'REFUND', 'VOID'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _load() => setState(() => _future = ApiService.getTransactions());

  List<Transaction> _filtered(List<Transaction> all) => all.where((t) {
        final fOk = _filter == 'ALL' || t.type == _filter;
        final q = _search.toLowerCase();
        final sOk = q.isEmpty ||
            t.id.toLowerCase().contains(q) ||
            t.outlet.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q);
        return fOk && sOk;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: _searchOpen
            ? TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                autofocus: true,
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search transactions…',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppTheme.textLight),
                ),
              )
            : const Text('Transactions',
                style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(_searchOpen ? Icons.close_rounded : Icons.search_rounded,
                size: 22),
            onPressed: () {
              setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _search = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _load,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primary, strokeWidth: 2.5));
          }
          final all = snap.data ?? Transaction.mockData();
          final filtered = _filtered(all);

          final totalVol = all
              .where((t) => t.type == 'SALE' && t.isApproved)
              .fold(0.0, (s, t) => s + t.amount);
          final declined = all.where((t) => t.isDeclined).length;

          return Column(
            children: [
              // ── Summary ──────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    _SumCard(
                        label: 'Volume',
                        value: '€${(totalVol / 1000).toStringAsFixed(1)}k',
                        color: AppTheme.primary),
                    const SizedBox(width: 10),
                    _SumCard(
                        label: 'Transactions',
                        value: '${all.length}',
                        color: AppTheme.accent),
                    const SizedBox(width: 10),
                    _SumCard(
                        label: 'Declined',
                        value: '$declined',
                        color: AppTheme.error),
                  ],
                ),
              ),

              // ── Filters ──────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: _filters.map((f) {
                    final active = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.primary
                                : const Color(0xFFF5F5F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 1),

              // ── List ─────────────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 44, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            const Text('No transactions',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 15)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length + 1,
                        itemBuilder: (_, i) {
                          if (i == 0) return const SizedBox(height: 8);
                          return _TxnTile(
                              txn: filtered[i - 1],
                              prevDate: i > 1 ? filtered[i - 2].createdAt : null);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Summary card ─────────────────────────────────────────────────────────────

class _SumCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SumCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────

class _TxnTile extends StatelessWidget {
  final Transaction txn;
  final DateTime? prevDate;
  const _TxnTile({required this.txn, this.prevDate});

  bool _newDay(DateTime a, DateTime? b) {
    if (b == null) return true;
    return a.day != b.day || a.month != b.month || a.year != b.year;
  }

  @override
  Widget build(BuildContext context) {
    final showDate = _newDay(txn.createdAt, prevDate);
    final df = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date separator
        if (showDate)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              _dayLabel(txn.createdAt),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary),
            ),
          ),
        // Tile
        GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      TransactionDetailScreen(transaction: txn))),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: txn.typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(txn.typeIcon, color: txn.typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(txn.description,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Text('${txn.outlet}  ·  ${txn.terminalId}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                // Right side
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(txn.formattedAmount,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: txn.type == 'REFUND'
                              ? AppTheme.warning
                              : AppTheme.textPrimary,
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: txn.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(txn.status,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: txn.statusColor)),
                        ),
                        const SizedBox(width: 6),
                        Text(df.format(txn.createdAt),
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textLight)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month) return 'Today';
    if (dt.day == now.day - 1 && dt.month == now.month) return 'Yesterday';
    return DateFormat('EEEE, dd MMM').format(dt);
  }
}
