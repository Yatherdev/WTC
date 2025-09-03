import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/invoice.dart';
import '../../providers/providers.dart';
import 'invoice_preview_page.dart';

class InvoicePage extends ConsumerWidget {
  final DateTime date;
  final List<Invoice> invoices;

  const InvoicePage({super.key, required this.date, required this.invoices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('فواتير بتاريخ ${DateFormat('yyyy-MM-dd').format(date)}'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: invoices.map((invoice) {
          final client = clients.firstWhere(
                (c) => c.key.toString() == invoice.clientId,
            orElse: () => Client(name: 'بدون اسم', phone: '', id: ''),
          );
          return Card(
            child: ListTile(
              leading: invoice.isPaid
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.schedule),
              title: Text('العميل: ${client.name}'),
              subtitle: Text('رقم الفاتورة: #${invoice.number}'),
              trailing: Text(invoice.totalAfterDiscount.toStringAsFixed(2)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoicePreviewPage(invoice: invoice),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}