import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class InvoicesListPage extends ConsumerWidget {
  const InvoicesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);
    final total = invoices.fold(0.0, (s, e) => s + e.totalAfterDiscount);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text('الفواتير')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              title: Text(total.toStringAsFixed(2)),
              trailing: const Text('إجمالي المبيعات',style: TextStyle(fontSize: 17),),
            ),
          ),
          const SizedBox(height: 8),
          ...invoices
              .map(
                (i) => Card(
                  child: ListTile(
                    leading:
                        i.isPaid
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : const Icon(Icons.schedule),
                    title: Text('#${i.number}'),
                    subtitle: Text(
                      i.date.toLocal().toString().split(' ').first,
                    ),
                    trailing: Text(i.totalAfterDiscount.toStringAsFixed(2)),
                    onTap: () => null,
                  ),
                ),
              )
        ],
      ),
    );
  }
}
