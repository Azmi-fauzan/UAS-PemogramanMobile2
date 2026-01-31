import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/finance_model.dart';


class FinanceYearDetailPage extends StatelessWidget {
  final String year;
  final List<FinanceModel> items;

  const FinanceYearDetailPage({
    super.key,
    required this.year,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
final total = items.fold(0, (sum, item) {
  if (item.type == 'income') {
    return sum + item.amount;
  } else {
    return sum - item.amount;
  }
});

    return Scaffold(
      appBar: AppBar(title: Text('Detail $year')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Total Pengeluaran'),
            trailing: Text('Rp $total'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(item.date),),
                  trailing: Text('Rp ${item.amount}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
