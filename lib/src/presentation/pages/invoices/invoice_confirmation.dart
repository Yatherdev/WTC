import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../domain/models/invoice.dart';
import '../../providers/providers.dart';


class InvoiceConfirmationPage extends ConsumerWidget {
  final Invoice invoice;
  final String shopName;
  final String? clientName;

  const InvoiceConfirmationPage({
    super.key,
    required this.invoice,
    required this.shopName,
    this.clientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalVolume = invoice.items.fold(0.0, (sum, item) => sum + item.volume);
    final totalPrice = invoice.totalAfterDiscount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد الفاتورة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (clientName != null)
              Text('العميل: $clientName', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('تفاصيل المنتجات:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: invoice.items
                    .map(
                      (item) => Card(
                    child: ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                          'م³: ${item.volume.toStringAsFixed(2)}\nالسعر: ${(item.totalValue ?? item.subtotal).toStringAsFixed(2)} ج.م'),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text('إجمالي التكعيب: ${totalVolume.toStringAsFixed(2)} م³',
                style: const TextStyle(fontSize: 16)),
            Text('إجمالي السعر: ${totalPrice.toStringAsFixed(2)} ج.م',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Center(
              child: FilledButton.icon(
                onPressed: () async {
                  try {
                    final invoiceId = await ref.read(invoicesProvider.notifier).createInvoice(
                      clientId: invoice.clientId,
                      items: invoice.items,
                      paymentType: invoice.paymentType,
                      discount: invoice.discount,
                      isPaid: invoice.isPaid,
                    );

                    if (invoice.paymentType == PaymentType.cash) {
                      await ref.read(cashboxProvider.notifier).addAmount(invoice.totalAfterDiscount);
                    }

                    final bytes = await generateInvoicePdf(
                      invoice: invoice,
                      shopName: shopName,
                    );
                    final dir = await getApplicationDocumentsDirectory();
                    final file = File('${dir.path}/invoice.pdf');
                    await file.writeAsBytes(await bytes);
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: clientName != null
                          ? 'فاتورة جديدة للعميل $clientName'
                          : 'فاتورة جديدة',
                    );

                    if (invoice.clientId != null) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/client_detail',
                        arguments: invoice.clientId,
                      );
                    } else {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('خطأ أثناء حفظ الفاتورة: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label: const Text('تأكيد وحفظ الفاتورة'),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}