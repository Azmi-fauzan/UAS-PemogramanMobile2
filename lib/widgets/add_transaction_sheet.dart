import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key,required this.onSuccess,});
  final VoidCallback onSuccess;


  @override
  State<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState
    extends State<AddTransactionSheet> {

  final titleController = TextEditingController();
  final amountController = TextEditingController();
  

  String type = 'expense';
  DateTime selectedDate = DateTime.now();
  

  Future<void> save() async {

    final userId =
        Supabase.instance.client.auth.currentUser!.id;

    await Supabase.instance.client
        .from('expenses')
        .insert({
      'user_id': userId,
      'title': titleController.text,
      'amount': int.parse(amountController.text),
      'type': type,
      'date': selectedDate.toIso8601String(),
    });
    widget.onSuccess();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            controller: titleController,
            decoration:
                const InputDecoration(labelText: "Title"),
          ),

          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: "Amount"),
          ),

          DropdownButton<String>(
            value: type,
            items: const [
              DropdownMenuItem(
                  value: 'expense',
                  child: Text("Expense")),
              DropdownMenuItem(
                  value: 'income',
                  child: Text("Income")),
            ],
            onChanged: (v) {
              setState(() {
                type = v!;
              });
            },
          ),

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: save,
            child: const Text("Save"),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}