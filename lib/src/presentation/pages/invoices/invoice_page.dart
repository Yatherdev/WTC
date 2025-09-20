import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/invoice.dart';
import '../../providers/providers.dart';
import 'invoice_preview_page.dart';

class InvoicePage extends ConsumerWidget {
  final DateTime? date;
  final List<Invoice> invoices;

  const InvoicePage({super.key, required this.date, required this.invoices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('الفواتير '),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          final client = clients.firstWhere(
            (c) => c.key.toString() == invoice.clientId,
            orElse: () => Client(name: 'بدون اسم', phone: '', id: ''),
          );

          final itemsCount = invoice.items.length;
          final formattedDate = DateFormat('yyyy/MM/dd - HH:mm').format(invoice.date);
          final total = invoice.totalAfterDiscount.toStringAsFixed(2);
          final paidChip = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: invoice.isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: invoice.isPaid ? Colors.green : Colors.orange),
            ),
            child: Text(
              invoice.isPaid ? 'كــاش' : 'آجــل',
              style: TextStyle(
                color: invoice.isPaid ? Colors.green[700] : Colors.orange[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          );

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoicePreviewPage(invoice: invoice),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        paidChip,
                        Text(
                          "العميل : ${client.name}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text('$itemsCount : عدد العناصر  ', style: const TextStyle(color: Colors.black54))),
                        Text(
                          ' رقم الفاتوره : ${invoice.number}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),

                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}