import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/finance_model.dart';
import '../../services/database_service.dart';
import 'finance_month_detail_page.dart';
import 'finance_year_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/add_transaction_sheet.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
  
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final supabase = Supabase.instance.client;
  String selectedType = 'expense';
  List<FinanceModel> allData = [];
 
 int balance = 0;

Map<String, List<FinanceModel>> monthlyData = {};
Map<String, List<FinanceModel>> yearlyData = {};


  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final month = DateFormat('yyyy-MM').format(DateTime.now());
  final year = DateFormat('yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    Future.microtask((){
    loadAll();
    });
  }

 Future<void> loadAll() async {
  allData = await DatabaseService().getAll();

  monthlyData = groupByMonth(allData);
  yearlyData = groupByYear(allData);

  balance = allData.fold(0, (sum, item) {
  return item.type == 'income'
      ? sum + item.amount
      : sum - item.amount;
});
print(allData.map((e) => e.amount).toList());

  setState(() {});
}

 Future<void> addExpense() async {

  final amount = int.tryParse(amountController.text);
  if (amount == null || noteController.text.isEmpty) return;
  

 final data = FinanceModel(
 
  title: noteController.text,
  amount: amount,
  category: 'Pengeluaran',
  date: DateTime.now(),
  type: selectedType,
);


  await DatabaseService().insertExpense(data);
  
  amountController.clear();
  noteController.clear();
  
  loadAll();
}

void showEditDialog(FinanceModel item) {
  final editAmount = TextEditingController(text: item.amount.toString());
  final editNote = TextEditingController(text: item.title);
  String editType = item.type;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Edit Catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
  DropdownButton<String>(
  value: editType,
  items: const [
    DropdownMenuItem(
      value: 'expense',
      child: Text("Pengeluaran"),
    ),
    DropdownMenuItem(
      value: 'income',
      child: Text("Pemasukan"),
    ),
  ],
  onChanged: (v) {
    setState(() {
      editType = v!;
    });
  },
),
          TextField(
            controller: editAmount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Nominal'),
          ),
          TextField(
            controller: editNote,
            decoration: const InputDecoration(labelText: 'Untuk apa'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            final amount = int.tryParse(editAmount.text);
            if (amount == null) return;

            final updated = FinanceModel(
              id: item.id,
              title: editNote.text,
              amount: amount,
              category: 'Pengeluaran',
              date: item.date,
              type: editType,
            );

            await DatabaseService().updateExpense(updated);
            Navigator.pop(context);
            loadAll();
          },
          child: const Text('Simpan'),
        ),
      ],
    ),
  );
}


@override
void dispose() {
  _tabController.dispose();
  amountController.dispose();
  noteController.dispose();
  super.dispose();
}



int totalDaily() {
  if (allData.isEmpty) return 0;

  return allData.fold(0, (sum, e) {
    if (e.type == 'income') {
      return sum + e.amount;
    } else {
      return sum - e.amount;
    }
  });
}

void openAddTransaction() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddTransactionSheet(
      onSuccess: loadAll,
      ),
  );
}

// finance_page.dart

Map<String, List<FinanceModel>> groupByMonth(List<FinanceModel> data) {
  final Map<String, List<FinanceModel>> result = {};

  for (var item in data) {
    final key = "${item.date.year}-${item.date.month}"; // yyyy-MM
    result.putIfAbsent(key, () => []);
    result[key]!.add(item);
  }

  return result;
}

Map<String, List<FinanceModel>> groupByYear(List<FinanceModel> data) {
  final Map<String, List<FinanceModel>> result = {};

  for (var item in data) {
    final key = "${item.date.year}"; // yyyy
    result.putIfAbsent(key, () => []);
    result[key]!.add(item);
  }

  return result;
}




  @override
  Widget build(BuildContext context) {


    return Scaffold(
    appBar: AppBar(
  title: const Text('Catatan Keuangan'),
      backgroundColor: const Color.fromARGB(255, 51, 84, 217),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
  bottom: TabBar(
    controller: _tabController,
    labelColor: Theme.of(context).primaryColor,
    unselectedLabelColor: Colors.white,
    indicatorColor: Theme.of(context).primaryColor,
    tabs: const [
      Tab(text: 'Harian'),
      Tab(text: 'Bulanan'),
      Tab(text: 'Tahunan'),
    ],
  ),
),floatingActionButton: FloatingActionButton(
    onPressed: openAddTransaction,
    child: const Icon(Icons.add),
  ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // HARIAN
      
                ListView.builder(
                  itemCount: allData.length,
                itemBuilder: (_, i) {
  final item = allData[i];
  
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: ListTile(
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(DateFormat('dd MMM yyyy').format(item.date)),
      leading: const Icon(Icons.payments_outlined),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rp ${item.signedAmount}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => showEditDialog(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await DatabaseService().deleteExpense(item.id!);
              loadAll();
            },
          ),
        ],
      ),
    ),
  );
},

                ),
              
          //     Padding(
          //       padding: const EdgeInsets.all(12),
          //       child: Column(
          //         children: [
          //           TextField(
          //             controller: amountController,
          //             keyboardType: TextInputType.number,
          //             decoration:
          //                 const InputDecoration(labelText: 'Nominal'),
          //           ),
          //           TextField(
          //             controller: noteController,
          //             decoration:
          //                 const InputDecoration(labelText: 'Untuk apa'),
          //           ),
          //           const SizedBox(height: 8),
          //           ElevatedButton(
          //             onPressed: addExpense,
          //             child: const Text('Tambah'),
          //           ),
          //         ],
          //       ),
          //     )
          //   ],
          // ),

 // BULANAN
ListView(
  children: monthlyData.entries.map((entry) {
final total = entry.value.fold(0, (sum, item) {
  return item.type == 'income'
      ? sum + item.amount
      : sum - item.amount;
});

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          entry.key, // yyyy-MM
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Jumlah transaksi: ${entry.value.length}'),
        trailing: Text(
          'Rp $total',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FinanceMonthDetailPage(
                month: entry.key,
                items: entry.value,
              ),
            ),
          );
        },
      ),
    );
  }).toList(),
),


          // TAHUNAN
// TAHUNAN
ListView(
  children: yearlyData.entries.map((entry) {
  final total = entry.value.fold(0, (sum, item) {
  return item.type == 'income'
      ? sum + item.amount
      : sum - item.amount;
});

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          entry.key, // yyyy
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Jumlah transaksi: ${entry.value.length}'),
        trailing: Text(
          'Rp $total',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FinanceYearDetailPage(
                year: entry.key,
                items: entry.value,
              ),
            ),
          );
        },
      ),
    );
  }).toList(),
),

        ],
      ),
    );
  }
}
