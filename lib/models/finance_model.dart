class FinanceModel {
  final String? id;
  final String title;
  final int amount;
  final String? category;
  final DateTime date;
  final String type;

  

  FinanceModel({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.type = 'expense',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

factory FinanceModel.fromMap(Map<String, dynamic> map) {
  return FinanceModel(
    id: map['id']?.toString(),
    title: map['title'] ?? '',
    amount: (map['amount'] as num?)?.toInt() ?? 0,
    category: map['category'] ?? 'Lainnya', // 🔥 FIX
    date: DateTime.parse(map['date']),
    type: map['type'] ?? 'expense', // 🔥 FIX
  );
}

int get signedAmount {
  return type == 'income'
      ? amount
      : -amount;
}

}
