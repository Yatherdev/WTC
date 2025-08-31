import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class DailyJournalPage extends ConsumerWidget {
  const DailyJournalPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoicesProvider);
    final today = DateTime.now();
    final ymd = DateTime(today.year, today.month, today.day);
    final dayInvoices = invoices.where((i) => DateTime(i.date.year, i.date.month, i.date.day) == ymd).toList();
    final sales = dayInvoices.fold(0.0, (s, e) => s + e.totalAfterDiscount);

    return Scaffold(
      appBar: AppBar(title: const Text('يومية المخزن')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Card(child: ListTile(title: Text('التاريخ: ${today.day}/${today.month}/${today.year}'))),
        const SizedBox(height: 8),
        Card(child: ListTile(title: const Text('الفواتير اليوم'), subtitle: Text(dayInvoices.map((i) => '#${i.number}').join(', ')))),
        Card(child: ListTile(title: const Text('المبيعات'), trailing: Text(sales.toStringAsFixed(2)))),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text('تصدير اليومية'))
      ]),
    );
  }
}