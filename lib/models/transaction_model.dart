import 'package:flutter/material.dart';
import '../utils/theme.dart';

class Transaction {
  final String id;
  final String merchantId;
  final double amount;
  final String currency;
  final String type; // SALE, REFUND, VOID
  final String status; // APPROVED, DECLINED, PENDING
  final String description;
  final String outlet;
  final String terminalId;
  final String cardLast4;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.merchantId,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.description,
    required this.outlet,
    required this.terminalId,
    required this.cardLast4,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      merchantId: json['merchant_id'] ?? 'demo',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'EUR',
      type: json['type'] ?? 'SALE',
      status: json['status'] ?? 'APPROVED',
      description: json['description'] ?? '',
      outlet: json['outlet'] ?? '',
      terminalId: json['terminal_id'] ?? '',
      cardLast4: json['card_last4'] ?? '****',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isRefund => type == 'REFUND';
  bool get isVoid => type == 'VOID';
  bool get isApproved => status == 'APPROVED';
  bool get isDeclined => status == 'DECLINED';

  Color get statusColor {
    switch (status) {
      case 'APPROVED': return AppTheme.success;
      case 'DECLINED': return AppTheme.error;
      default: return AppTheme.warning;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'SALE':   return AppTheme.success;
      case 'REFUND': return AppTheme.warning;
      case 'VOID':   return AppTheme.error;
      default:       return AppTheme.textLight;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'SALE':   return Icons.arrow_upward_rounded;
      case 'REFUND': return Icons.arrow_downward_rounded;
      case 'VOID':   return Icons.remove_circle_outline_rounded;
      default:       return Icons.swap_horiz_rounded;
    }
  }

  String get formattedAmount {
    final sign = type == 'REFUND' ? '-' : '';
    return '$sign${currency == 'GBP' ? '£' : '€'}${amount.toStringAsFixed(2)}';
  }

  static List<Transaction> mockData() {
    final now = DateTime.now();
    return [
      Transaction(id: 'TXN-001', merchantId: 'demo', amount: 125.50, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',     outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '4242', createdAt: now.subtract(const Duration(hours: 2))),
      Transaction(id: 'TXN-002', merchantId: 'demo', amount: 89.99,  currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Contactless Pay',  outlet: 'Branch 1',    terminalId: 'TRM-002', cardLast4: '1234', createdAt: now.subtract(const Duration(hours: 5))),
      Transaction(id: 'TXN-003', merchantId: 'demo', amount: 250.00, currency: 'GBP', type: 'REFUND', status: 'APPROVED',  description: 'Customer Refund',  outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '4242', createdAt: now.subtract(const Duration(hours: 8))),
      Transaction(id: 'TXN-004', merchantId: 'demo', amount: 342.80, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',     outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '5678', createdAt: now.subtract(const Duration(days: 1, hours: 2))),
      Transaction(id: 'TXN-005', merchantId: 'demo', amount: 67.00,  currency: 'EUR', type: 'SALE',   status: 'DECLINED',  description: 'Chip & PIN',       outlet: 'Branch 2',    terminalId: 'TRM-003', cardLast4: '9999', createdAt: now.subtract(const Duration(days: 1, hours: 6))),
      Transaction(id: 'TXN-006', merchantId: 'demo', amount: 510.00, currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Tap & Pay',        outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '4242', createdAt: now.subtract(const Duration(days: 2, hours: 3))),
      Transaction(id: 'TXN-007', merchantId: 'demo', amount: 189.90, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',     outlet: 'Branch 1',    terminalId: 'TRM-002', cardLast4: '1234', createdAt: now.subtract(const Duration(days: 2, hours: 8))),
      Transaction(id: 'TXN-008', merchantId: 'demo', amount: 75.50,  currency: 'EUR', type: 'VOID',   status: 'APPROVED',  description: 'Transaction Void', outlet: 'Branch 2',    terminalId: 'TRM-003', cardLast4: '3333', createdAt: now.subtract(const Duration(days: 3, hours: 1))),
      Transaction(id: 'TXN-009', merchantId: 'demo', amount: 420.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Online Payment',   outlet: 'E-Commerce',  terminalId: 'TRM-WEB', cardLast4: '2222', createdAt: now.subtract(const Duration(days: 3, hours: 7))),
      Transaction(id: 'TXN-010', merchantId: 'demo', amount: 55.00,  currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Contactless',      outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '4242', createdAt: now.subtract(const Duration(days: 4, hours: 4))),
      Transaction(id: 'TXN-011', merchantId: 'demo', amount: 980.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Card Payment',     outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '7777', createdAt: now.subtract(const Duration(days: 4, hours: 9))),
      Transaction(id: 'TXN-012', merchantId: 'demo', amount: 130.00, currency: 'EUR', type: 'REFUND', status: 'APPROVED',  description: 'Partial Refund',   outlet: 'Branch 1',    terminalId: 'TRM-002', cardLast4: '1234', createdAt: now.subtract(const Duration(days: 5, hours: 2))),
      Transaction(id: 'TXN-013', merchantId: 'demo', amount: 289.99, currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Chip & PIN',       outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '4242', createdAt: now.subtract(const Duration(days: 5, hours: 9))),
      Transaction(id: 'TXN-014', merchantId: 'demo', amount: 44.99,  currency: 'EUR', type: 'SALE',   status: 'DECLINED',  description: 'Tap & Pay',        outlet: 'Branch 2',    terminalId: 'TRM-003', cardLast4: '8888', createdAt: now.subtract(const Duration(days: 6, hours: 3))),
      Transaction(id: 'TXN-015', merchantId: 'demo', amount: 670.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Online Payment',   outlet: 'E-Commerce',  terminalId: 'TRM-WEB', cardLast4: '6666', createdAt: now.subtract(const Duration(days: 6, hours: 6))),
      Transaction(id: 'TXN-016', merchantId: 'demo', amount: 199.00, currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Online Payment',   outlet: 'E-Commerce',  terminalId: 'TRM-WEB', cardLast4: '2222', createdAt: now.subtract(const Duration(days: 7, hours: 5))),
      Transaction(id: 'TXN-017', merchantId: 'demo', amount: 350.00, currency: 'GBP', type: 'SALE',   status: 'APPROVED',  description: 'Contactless',      outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '4242', createdAt: now.subtract(const Duration(days: 8, hours: 2))),
      Transaction(id: 'TXN-018', merchantId: 'demo', amount: 89.00,  currency: 'EUR', type: 'VOID',   status: 'APPROVED',  description: 'Transaction Void', outlet: 'Branch 1',    terminalId: 'TRM-002', cardLast4: '1234', createdAt: now.subtract(const Duration(days: 9, hours: 6))),
      Transaction(id: 'TXN-019', merchantId: 'demo', amount: 1250.00,currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Corporate Card',   outlet: 'Main Store',  terminalId: 'TRM-001', cardLast4: '5555', createdAt: now.subtract(const Duration(days: 10, hours: 7))),
      Transaction(id: 'TXN-020', merchantId: 'demo', amount: 45.00,  currency: 'EUR', type: 'SALE',   status: 'APPROVED',  description: 'Chip & PIN',       outlet: 'Branch 2',    terminalId: 'TRM-003', cardLast4: '3333', createdAt: now.subtract(const Duration(days: 12, hours: 3))),
    ];
  }
}
