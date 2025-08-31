import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../data/hive/hive_services.dart';
import '../../../domain/models/invoice.dart';
import '../invoices/invoice_edite_page.dart';


class InvoicesByDatePage extends StatelessWidget {
  final String date;

  const InvoicesByDatePage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Invoice>(HiveService.invoicesBox);
    final invoices = box.values
        .where((invoice) =>
    DateFormat('yyyy-MM-dd').format(invoice.date) == date)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('فواتير بتاريخ $date'),
      ),
      body: invoices.isEmpty
          ? const Center(child: Text('لا توجد فواتير لهذا التاريخ'))
          : ListView(
        padding: const EdgeInsets.all(12),
        children: invoices
            .map(
              (invoice) => Card(
            child: ListTile(
              title: Text('#${invoice.number}'),
              subtitle:
              Text(invoice.date.toLocal().toString().split(' ').first),
              trailing: Text(
                  invoice.totalAfterDiscount.toStringAsFixed(2)),
              leading: invoice.paymentType == PaymentType.credit
                  ? const Icon(Icons.credit_card, color: Colors.red)
                  : const Icon(Icons.money, color: Colors.green),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InvoiceEditPage(id: invoice.id),
                  ),
                );
              },
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}