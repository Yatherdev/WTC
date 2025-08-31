import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../../domain/models/invoice.dart';

Future<Future<Uint8List>> generateInvoicePdf({
  required Invoice invoice,
  required String shopName,
  String? clientName,
}) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(shopName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('رقم الفاتورة: ${invoice.number}', style: pw.TextStyle(fontSize: 16)),
            pw.Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(invoice.date)}', style: pw.TextStyle(fontSize: 16)),
            if (clientName != null) pw.Text('العميل: $clientName', style: pw.TextStyle(fontSize: 16)),
            pw.Text('تفاصيل المنتجات:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.ListView.builder(
              itemCount: invoice.items.length,
              itemBuilder: (context, index) {
                final item = invoice.items[index];
                return pw.Container(
                  margin: pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('منتج: ${item.product.name}', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('الحجم (م³): ${item.volume.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('القيمة: ${(item.totalValue ?? item.subtotal).toStringAsFixed(2)} ج.م', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
            pw.Text('التكعيب الإجمالي: ${invoice.items.fold(0.0, (sum, item) => sum + item.volume).toStringAsFixed(2)} م³',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('السعر الإجمالي: ${invoice.totalAfterDiscount.toStringAsFixed(2)} ج.م',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('طريقة الدفع: ${invoice.paymentType == PaymentType.cash ? 'نقدي' : 'آجل'}',
                style: pw.TextStyle(fontSize: 16)),
          ],
        );
      },
    ),
  );
  return pdf.save();
}