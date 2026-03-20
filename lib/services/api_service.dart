import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class ApiService {
  // Android emulator uses 10.0.2.2 to reach host localhost
  // For real device on same WiFi, replace with your PC's local IP
  static const String _baseUrl = 'http://10.0.2.2:3000/api';
  static const Duration _timeout = Duration(seconds: 5);

  static Future<bool> isAvailable() async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Transactions ──────────────────────────────────────────────────────────

  static Future<List<Transaction>> getTransactions({
    String merchantId = 'demo',
    String? type,
  }) async {
    try {
      var url = '$_baseUrl/transactions?merchant_id=$merchantId&limit=50';
      if (type != null) url += '&type=$type';
      final res = await http.get(Uri.parse(url)).timeout(_timeout);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((j) => Transaction.fromJson(j)).toList();
      }
    } catch (_) {
      // Backend not reachable → use mock data
    }
    return Transaction.mockData();
  }

  static Future<Transaction?> getTransaction(String id) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/transactions/$id'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return Transaction.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getStats({
    String merchantId = 'demo',
  }) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/stats?merchant_id=$merchantId'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        double totalVolume = 0;
        int totalCount = 0;
        for (final row in data) {
          totalVolume += (row['total_volume'] as num? ?? 0).toDouble();
          totalCount += (row['total_count'] as num? ?? 0).toInt();
        }
        return {'total_volume': totalVolume, 'total_count': totalCount};
      }
    } catch (_) {}
    // Compute from mock data
    final txns = Transaction.mockData();
    final volume = txns
        .where((t) => t.type == 'SALE' && t.isApproved)
        .fold(0.0, (sum, t) => sum + t.amount);
    return {'total_volume': volume, 'total_count': txns.length};
  }

  // ── Merchants ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getMerchant(String id) async {
    try {
      final res = await http
          .get(Uri.parse('$_baseUrl/merchants/$id'))
          .timeout(_timeout);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> saveMerchant(Map<String, dynamic> data) async {
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/merchants'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(_timeout);
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
