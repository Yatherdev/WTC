import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/models/invoice.dart';
import '../../domain/models/client.dart';
import 'package:hive/hive.dart';
import '../../data/hive/hive_services.dart';

Future<Future<Uint8List>> generateInvoicePdf({
  required Invoice invoice,
  required String shopName,
}) async {
  final pdf = pw.Document();
  final clientBox = Hive.box<Client>(HiveService.clientsBox);
  final client = clientBox.values.firstWhere(
        (c) => c.key.toString() == invoice.clientId,
    orElse: () => Client(name: 'بدون اسم', phone: '', id: ''),
  );

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('فاتورة', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Text('اسم المتجر: $shopName'),
        pw.Text('اسم العميل: ${client.name}'),
        pw.Text('رقم الفاتورة: #${invoice.number}'),
        pw.Text('التاريخ: ${invoice.date.toString().substring(0, 16)}'),
        pw.Text('نوع الدفع: ${invoice.paymentType == PaymentType.cash ? 'كاش' : 'آجل'}'),
        pw.Divider(),
        pw.Column(
          children: invoice.items.map((item) {
            return pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('اسم المنتج: ${item.product.name}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  if (item.product.directVolume != null)
                    pw.Text('الحجم: ${item.volume.toStringAsFixed(4)} م³'),
                  if (item.product.variants.isNotEmpty)
                    ...item.product.variants.map((v) => pw.Text('طول: ${v.length} م, كمية: ${v.quantity}')),
                  pw.Text('سعر المتر المكعب: ${item.pricePerM3.toStringAsFixed(2)}'),
                  pw.Text('الإجمالي: ${item.subtotal.toStringAsFixed(2)}'),
                ],
              ),
            );
          }).toList(),
        ),
        pw.Divider(),
        pw.Text('الإجمالي قبل الخصم: ${invoice.totalBeforeDiscount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.Text('الخصم: ${invoice.discount.toStringAsFixed(2)}',
            style: const pw.TextStyle(fontSize: 18)),
        pw.Text('الإجمالي بعد الخصم: ${invoice.totalAfterDiscount.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ],
    ),
  );

  return pdf.save();
}