import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/models/client.dart';
import '../../domain/models/invoice.dart';

Future<Uint8List> generateInvoicePdf({
  required Invoice invoice,
  required String shopName,
}) async {
  final pdf = pw.Document();

  // تحميل الخط العربي
  final fontData = await rootBundle.load("assets/fonts/Cairo-Bold.ttf");
  final ttf = pw.Font.ttf(fontData);

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            "شركه الإيمان لإستيراد وتجاره الأخشاب",
            style: pw.TextStyle(
              font: ttf,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
            textDirection: pw.TextDirection.rtl, // مهم جداً
          ),
        ),
        pw.SizedBox(height: 20),

        pw.Center(
          child: pw.Text(
            invoice.isPaid ? "كــاش" : "آجــل",
            style: pw.TextStyle(
              font: ttf,
              fontSize: 16,
              color: invoice.isPaid ? PdfColors.green : PdfColors.orange,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ),
        pw.SizedBox(height: 20),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              invoice.number,
              style: pw.TextStyle(font: ttf),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.Text(
              "رقم الفاتورة",
              style: pw.TextStyle(font: ttf),
              textDirection: pw.TextDirection.rtl,
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(),
          headers: [
            pw.Text("البيان",textDirection: pw.TextDirection.rtl,style: pw.TextStyle(font: ttf, fontSize: 10),),
            pw.Text("اسم المنتج",textDirection: pw.TextDirection.rtl,style: pw.TextStyle(font: ttf, fontSize: 10),),
            pw.Text("الطول",textDirection: pw.TextDirection.rtl,style: pw.TextStyle(font: ttf, fontSize: 10),),
            pw.Text("الكمية",textDirection: pw.TextDirection.rtl,style: pw.TextStyle(font: ttf, fontSize: 10),),
            pw.Text("الحجم م³",textDirection: pw.TextDirection.rtl,style: pw.TextStyle(font: ttf, fontSize: 10),),
            pw.Text("سعر المتر",textDirection: pw.TextDirection.rtl,style: pw.TextStyle(font: ttf, fontSize: 10),),
            pw.Text("القيمه",textDirection: pw.TextDirection.rtl,style: pw.TextStyle(font: ttf, fontSize: 10),),


          ],

          headerStyle: pw.TextStyle(
            font: ttf,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: pw.TextStyle(font: ttf),
          headerDecoration: pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          cellAlignment: pw.Alignment.center,
          data: invoice.items.map((item) {
            return [
              item.size.toString(),
              item.product.name,
              item.product.variants.isNotEmpty
                  ? item.product.variants.first.length.toString()
                  : "-",
              item.product.variants.isNotEmpty
                  ? item.product.variants.first.quantity.toString()
                  : "1",
              item.volume.toStringAsFixed(4),
              item.pricePerM3.toStringAsFixed(2),
              item.subtotal.toStringAsFixed(2),
            ];
          }).toList(),
        ),
        pw.SizedBox(height: 20),

        pw.Text(
          "الإجمالي قبل الخصم: ${invoice.totalBeforeDiscount.toStringAsFixed(2)} ج.م",
          style: pw.TextStyle(font: ttf, fontSize: 14),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          "الخصم: ${invoice.discount.toStringAsFixed(2)} ج.م",
          style: pw.TextStyle(font: ttf, fontSize: 14),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Text(
          "الإجمالي بعد الخصم: ${invoice.totalAfterDiscount.toStringAsFixed(2)} ج.م",
          style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    ),
  );

  return pdf.save();
}