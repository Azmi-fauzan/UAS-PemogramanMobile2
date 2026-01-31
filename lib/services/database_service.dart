import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/finance_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class DatabaseService {
  final supabase = Supabase.instance.client;
  User get user => supabase.auth.currentUser!;
  static Database? _db;
  

  
  

   Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

   Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'finance.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE finance (
           final string id;,
    title TEXT,
    amount INTEGER,
    category TEXT,
    date TEXT
          )
        ''');
      },
    );
  }

  // INSERT
Future<void> insertExpense(FinanceModel data) async {

  final user = Supabase.instance.client.auth.currentUser!;

  await supabase.from('expenses')
      .insert({
        'user_id': user.id,
        'title': data.title,
        'amount': data.amount,
        'category': data.category,
        'date': data.date.toIso8601String(),
        'type': data.type,
      });
}

  // HARIAN
   Future<List<FinanceModel>> getDaily(String date) async {
    final db = await database;
    final res = await db.query(
      'finance',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
    return res.map((e) => FinanceModel.fromMap(e)).toList();
  }

  // BULANAN
Future<int> getTotalMonthly(DateTime date) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) throw Exception("Not logged in");

  final start = DateTime(date.year, date.month, 1);
  final end = DateTime(date.year, date.month + 1, 1);

  final response = await supabase
      .from('expenses')
      .select('amount, type') // 🔥 WAJIB TAMBAH TYPE
      .eq('user_id', user.id)
      .gte('date', start.toIso8601String())
      .lt('date', end.toIso8601String());

  int total = 0;

  for (final item in response) {
    final amount = (item['amount'] as num).toInt();

   if ((item['type'] ?? '').toString().toLowerCase() == 'income'){
      total += amount;
    } else {
      total -= amount;
    }
  }

  return total;
}

  // TAHUNAN
   Future<List<Map<String, dynamic>>> getYearly(String year) async {
    final db = await database;
    return db.rawQuery('''
      SELECT substr(date, 1, 7) as month, SUM(amount) as total
      FROM finance
      WHERE date LIKE ?
      GROUP BY month
      ORDER BY month DESC
    ''', ['$year%']);
  }

Future<void> deleteExpense(String id) async {
  await supabase
      .from('expenses')
      .delete()
      .eq('id', id)
      .eq('user_id', user.id);
}

Future<void> updateExpense(FinanceModel data) async {
await supabase;
  Supabase.instance.client
      .from('expenses')
      .update({
        'title': data.title,
        'amount': data.amount,
        'category': data.category,
        'date': data.date.toIso8601String(),
        'type': data.type,
      })
      .eq('id', data.id!)
      .eq('user_id', user.id);
}


Future<List<FinanceModel>> getAll() async {

  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  final response = await supabase
      .from('expenses')
      .select()
      // .eq('user_id', user.id)
      .order('date', ascending: false);

  return (response as List)
      .map((e) => FinanceModel.fromMap(e))
      .toList();
}

Future<int> getTotalSalesToday() async {
  final nowUtc = DateTime.now().toUtc();
  final startUtc = DateTime.utc(
    nowUtc.year,
    nowUtc.month,
    nowUtc.day,
  );
  final endUtc = startUtc.add(const Duration(days: 1));

  final response = await supabase
      .from('transaction')
      .select('total')
      .gte('created_at', startUtc.toIso8601String())
      .lt('created_at', endUtc.toIso8601String());

  int total = 0;
  for (final row in response) {
    total += row['total'] as int;
  }

  return total;
}

Future<void> addExpense({
  required String title,
  required int amount,
  required DateTime date,
}) async {

  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  await supabase.from('expenses').insert({
    'user_id': user.id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    
  });
}

Future<List<FinanceModel>> getDailySupabase(DateTime date) async {

  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception("User not logged in");
  }

  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));

  final response = await supabase
      .from('expenses')
      .select()
      .eq('user_id', user.id)
      .gte('date', start.toIso8601String())
      .lt('date', end.toIso8601String())
      .order('date', ascending: false);

  return response
      .map<FinanceModel>((e) => FinanceModel.fromMap(e))
      .toList();
}

Future<int> getBalance() async {

  final userId = supabase.auth.currentUser!.id;

  final response = await supabase
      .from('expenses')
      .select('amount, type')
      .eq('user_id', userId);

  int balance = 0;

  for (final item in response) {
    final amount = (item['amount'] as num).toInt();

    if ((item['type'] ?? '').toString().toLowerCase() == 'income'){
      balance += amount;
    } else {
      balance -= amount;
    }
  }
for (final item in response) {
  print("TYPE DB => ${item['type']}");
}
  return balance;
}

Future<int> getTodayExpense() async {

  final userId = supabase.auth.currentUser!.id;

  final start = DateTime.now();
  final beginningOfDay = DateTime(start.year, start.month, start.day);
  final endOfDay = beginningOfDay.add(const Duration(days: 1));

  final response = await supabase
      .from('expenses')
      .select('amount')
      .eq('user_id', userId)
      .eq('type', 'expense') // 🔥 penting
      .gte('date', beginningOfDay.toIso8601String())
      .lt('date', endOfDay.toIso8601String());

  int total = 0;

  for (final item in response) {
    total += (item['amount'] as num).toInt();
  }

  return total;
}




  
}
