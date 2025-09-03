import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../domain/models/invoice.dart';
import '../../../domain/models/client.dart';
import '../../providers/providers.dart';

class InvoicePreviewPage extends ConsumerWidget {
  final Invoice invoice;

  const InvoicePreviewPage({super.key, required this.invoice});

  Future<File> _generatePdf(BuildContext context, String shopName) async {
    final bytes = await generateInvoicePdf(invoice: invoice, shopName: shopName);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_${invoice.number}.pdf');
    await file.writeAsBytes(await bytes);
    return file;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final client = clients.firstWhere(
          (c) => c.key.toString() == invoice.clientId,
      orElse: () => Client(name: 'بدون اسم', phone: '', id: ''),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('فاتورة #${invoice.number}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اسم العميل: ${client.name}', style: const TextStyle(fontSize: 18)),
            Text('رقم الفاتورة: #${invoice.number}', style: const TextStyle(fontSize: 18)),
            Text('التاريخ: ${invoice.date.toString().substring(0, 16)}',
                style: const TextStyle(fontSize: 18)),
            Text('نوع الدفع: ${invoice.paymentType == PaymentType.cash ? 'كاش' : 'آجل'}',
                style: const TextStyle(fontSize: 18)),
            const Divider(thickness: 2),
            const Text('المنتجات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: invoice.items.length,
                itemBuilder: (context, index) {
                  final item = invoice.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('اسم المنتج: ${item.product.name}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          if (item.product.directVolume != null)
                            Text('الحجم: ${item.volume.toStringAsFixed(4)} م³'),
                          if (item.product.variants.isNotEmpty)
                            ...item.product.variants.map((variant) => Text(
                                'طول: ${variant.length} م, كمية: ${variant.quantity}')),
                          Text('سعر المتر المكعب: ${item.pricePerM3.toStringAsFixed(2)} ج.م'),
                          Text('الإجمالي: ${item.subtotal.toStringAsFixed(2)} ج.م'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 2),
            Text('الإجمالي قبل الخصم: ${invoice.totalBeforeDiscount.toStringAsFixed(2)} ج.م',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('الخصم: ${invoice.discount.toStringAsFixed(2)} ج.م',
                style: const TextStyle(fontSize: 18)),
            Text('الإجمالي بعد الخصم: ${invoice.totalAfterDiscount.toStringAsFixed(2)} ج.م',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final file = await _generatePdf(context, 'متجري');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم حفظ الفاتورة في: ${file.path}')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ PDF'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final file = await _generatePdf(context, 'متجري');
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text: 'فاتورة #${invoice.number} للعميل ${client.name}',
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة PDF'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}