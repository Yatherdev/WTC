import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/expense.dart';
import '../../providers/providers.dart';
import 'package:uuid/uuid.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpensesPage> createState() => _State();
}

class _State extends ConsumerState<ExpensesPage> {
  final amount = TextEditingController();
  final purpose = TextEditingController();

  @override
  void dispose() {
    amount.dispose();
    purpose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(expensesProvider);
    final total = data.fold(0.0, (s, e) => s + e.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('المصروفات')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final id = const Uuid().v4();
          final e = Expense(
            id: id,
            amount: double.tryParse(amount.text) ?? 0,
            purpose: purpose.text,
            date: DateTime.now(),
          );
          await ref.read(expensesProvider.notifier).add(e);
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              title: const Text('إجمالي المصروفات'),
              trailing: Text(total.toStringAsFixed(2)),
            ),
          ),
          const SizedBox(height: 8),
          ...data
              .map(
                (e) => Card(
                  child: ListTile(
                    title: Text(e.purpose),
                    subtitle: Text(
                      e.date.toLocal().toString().split(' ').first,
                    ),
                    trailing: Text(e.amount.toStringAsFixed(2)),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
