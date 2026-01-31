import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../utils/currency_formater.dart';


class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  int totalMonthly = 0;
  int totalToday = 0;
  int balance = 0;
  int todayExpense = 0;
bool isLoading = true;

  Future<void> reload() async {
  await loadTodaySales();
  await loadMonthly();
  await loadBalance();
  await loadTodayExpense();
}

Future<void> loadTodayExpense() async {

  final result = await DatabaseService().getTodayExpense();

  setState(() {
    todayExpense = result;
  });
}

 


  @override
  void initState() {
    super.initState();
    loadBalance();
    loadMonthly();
    loadTodaySales();
    loadTodayExpense();

  }


Future<void> loadBalance() async {
  final result = await DatabaseService().getBalance();

print("BALANCE BARU => $result");

  setState(() {
    balance = result;
    isLoading = false;
  });
}

  Future<void> loadTodaySales() async {
  final total = await DatabaseService().getTotalSalesToday();
  if (!mounted) return;

  setState(() {
    totalToday = total;
  });
}

  Future<void> loadMonthly() async {
  final now = DateTime.now();
final total = await DatabaseService().getTotalMonthly(now);

    if (!mounted) return;
    setState(() => totalMonthly = total);
  }

Widget _statCard({
  required String title,
  required int amount,
  required IconData icon,
}) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 16),

          /// TEXT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatRupiah(amount),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
// @override
// Widget build(BuildContext context) {
//   return RefreshIndicator(
//     onRefresh: reload,
//     child: ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       children: [

//         /// HEADER
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.fromLTRB(24, 40, 24, 50),
//           decoration: BoxDecoration(
//             color: Theme.of(context).primaryColor,
//             borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(32),
//               bottomRight: Radius.circular(32),
//             ),
//           ),
//           child: const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Dashboard',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 6),
//               Text(
//                 'Ringkasan aktivitas bulan ini',
//                 style: TextStyle(color: Colors.white70),
//               ),
//             ],
//           ),
//         ),

//         /// BALANCE CARD (Hero Card)
//         Transform.translate(
//           offset: const Offset(0, -10),
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   Color(0xff3A7BD5),
//                   Color(0xff00d2ff),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   blurRadius: 20,
//                   color: Colors.blue.withOpacity(0.25),
//                   offset: const Offset(0, 10),
//                 )
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Total Saldo",
//                   style: TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Rp $balance",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),

//         const SizedBox(height: 8),

//         /// MONTHLY CARD
//         _statCard(
//           title: "Pengeluaran Hari Ini",
//           amount: todayExpense,
//           icon: Icons.calendar_month,
//         ),

//         const SizedBox(height: 16),

//         /// TODAY CARD
//         _statCard(
//           title: "Penjualan Hari Ini",
//           amount: totalToday,
//           icon: Icons.today,
//         ),

//         const SizedBox(height: 40),
//       ],
//     ),
//   );
// }
@override
Widget build(BuildContext context) {
  return RefreshIndicator(
    onRefresh: reload,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [

        /// HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Ringkasan aktivitas bulan ini',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),

        /// JARAK NATURAL (INI KUNCI)
        const SizedBox(height: 24),

        /// HERO BALANCE CARD (TIDAK OVERLAP)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff3A7BD5),
                Color(0xff00d2ff),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Saldo",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                formatRupiah(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        /// PENGELUARAN HARI INI
        _statCard(
          title: "Pengeluaran Hari Ini",
          amount: todayExpense,
          icon: Icons.arrow_downward,
        ),

        const SizedBox(height: 16),

        /// PENJUALAN HARI INI
        _statCard(
          title: "Penjualan Hari Ini",
          amount: totalToday,
          icon: Icons.shopping_bag,
        ),

        const SizedBox(height: 40),
      ],
    ),
  );
}
}