import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/invoice.dart';
import '../../providers/providers.dart';
import '../invoices/invoice_preview_page.dart';

class ClientDetailPage extends ConsumerWidget {
  final String id;

  const ClientDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final invoices = ref.watch(invoicesProvider);
    final client = clients.firstWhere((c) => c.key.toString() == id, orElse: () => Client(name: 'غير موجود', phone: '', id: ''));
    final clientInvoices = invoices.where((i) => i.clientId == id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(client.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('الاسم: ${client.name}', style: const TextStyle(fontSize: 18)),
          Text('رقم الهاتف: ${client.phone}', style: const TextStyle(fontSize: 18)),
          const Divider(thickness: 2),
          const Text('الفواتير:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (clientInvoices.isEmpty)
            const Center(child: Text('لا توجد فواتير لهذا العميل', style: TextStyle(color: Colors.grey))),
          ...clientInvoices.map((invoice) => Card(
            child: ListTile(
              leading: invoice.isPaid
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.schedule),
              title: Text('فاتورة #${invoice.number}'),
              subtitle: Text(invoice.date.toString().substring(0, 16)),
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
          )),
        ],),
      ),
    );
  }
}