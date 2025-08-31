import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../../../data/hive/hive_services.dart';
import '../../../domain/models/invoice.dart';
import 'invoicebydate.dart';
 // صفحة جديدة سننشئها

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final box = Hive.box<Invoice>(HiveService.invoicesBox);

    // تجميع التواريخ الفريدة من الفواتير
    final dates = box.values
        .map((invoice) => DateFormat('yyyy-MM-dd').format(invoice.date))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // ترتيب تنازلي

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الفواتير حسب التاريخ'),
      ),
      body: dates.isEmpty
          ? const Center(child: Text('لا توجد فواتير'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          return Card(
            child: ListTile(
              title: Text(date),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoicesByDatePage(date: date),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/product_form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}