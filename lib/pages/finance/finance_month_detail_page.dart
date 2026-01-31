import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/finance_model.dart';

class FinanceMonthDetailPage extends StatelessWidget {
  final String month;
  final List<FinanceModel> items;

  const FinanceMonthDetailPage({
    super.key,
    required this.month,
    required this.items,
  });

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final int total = items.fold<int>(
      0,
      (sum, item) => sum + item.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail $month'),
      ),
      body: Column(
        children: [
          // 🔹 Ringkasan total
          ListTile(
            title: const Text('Total Bulan Ini'),
            trailing: Text(
              'Rp $total',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          const Divider(),

          // 🔹 Daftar transaksi
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return ListTile(
                  leading: const Icon(Icons.calendar_today, size: 18),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    formatDate(item.date), // ✅ TANGGAL TAMPIL
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Text(
                    'Rp ${item.amount}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
