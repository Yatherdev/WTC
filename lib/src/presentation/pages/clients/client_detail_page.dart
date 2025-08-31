import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../data/hive/hive_services.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/invoice.dart';
import '../../providers/providers.dart';

class ClientDetailPage extends ConsumerWidget {
  final String id;
  const ClientDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? parsedId = int.tryParse(id);
    if (parsedId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('معرف العميل غير صالح')),
      );
    }

    final clientBox = Hive.box<Client>(HiveService.clientsBox);
    final client = clientBox.get(parsedId);

    if (client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('العميل غير موجود')),
      );
    }

    final invoices = ref.watch(invoicesProvider).where((i) => i.clientId == id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('فواتير العميل: ${client.name}'),
        centerTitle: true,
      ),
      body: invoices.isEmpty
          ? const Center(
        child: Text(
          'لا توجد فواتير لهذا العميل',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(12),
        children: invoices
            .map(
              (i) => Card(
            child: ListTile(
              title: Text('#${i.number}'),
              subtitle: Text(i.date.toLocal().toString().split(' ').first),
              trailing: Text(i.totalAfterDiscount.toStringAsFixed(2)),
              leading: i.paymentType == PaymentType.credit
                  ? const Icon(Icons.credit_card, color: Colors.red) // 🟢 أيقونة للفواتير الآجلة
                  : const Icon(Icons.money, color: Colors.green), // 🟢 أيقونة للفواتير الكاش
              //onTap: () => Navigator.push(context, MaterialPageRoute(builder: builder)),
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}