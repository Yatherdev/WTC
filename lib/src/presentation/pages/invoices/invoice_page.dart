import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic> data;

  const InvoicePage({super.key, required this.data});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Future<File> _generatePdf() async {
    final pdf = pw.Document();

    final clientName = widget.data['clientName'] ?? 'بدون اسم';
    final invoiceNumber = widget.data['invoiceNumber'] ?? '';
    final date = widget.data['date'] ?? DateTime.now();
    final products =
        widget.data['products'] as List<Map<String, dynamic>>? ?? [];

    double totalBeforeDiscount = 0;
    double totalAfterDiscount = 0;

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Text("فاتورة", style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text("اسم العميل: $clientName"),
            pw.Text("رقم الفاتورة: $invoiceNumber"),
            pw.Text("التاريخ: ${date.toString().substring(0, 16)}"),
            pw.Divider(),

            pw.Column(
              children: products.map((product) {
                final name = product['name'] ?? '';
                final qty = (product['quantity'] ?? 1).toString();
                final price = (product['price'] ?? 0).toDouble();
                final discount = (product['discount'] ?? 0).toDouble();

                final subtotal = price * (int.tryParse(qty) ?? 1);
                final subtotalAfter = subtotal - (subtotal * discount / 100);

                totalBeforeDiscount += subtotal;
                totalAfterDiscount += subtotalAfter;

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
                      pw.Text("اسم المنتج: $name", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text("الكمية: $qty"),
                      pw.Text("سعر الوحدة: $price"),
                      pw.Text("السعر قبل الخصم: $subtotal"),
                      pw.Text("السعر بعد الخصم: $subtotalAfter"),
                    ],
                  ),
                );
              }).toList(),
            ),

            pw.Divider(),
            pw.Text("الإجمالي قبل الخصم: $totalBeforeDiscount",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text("الإجمالي بعد الخصم: $totalAfterDiscount",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/invoice.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _savePdf() async {
    final file = await _generatePdf();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حفظ الفاتورة في: ${file.path}")),
    );
  }

  Future<void> _sharePdf() async {
    final file = await _generatePdf();
    await Share.shareXFiles([XFile(file.path)], text: "فاتورة جديدة");
  }

  @override
  Widget build(BuildContext context) {
    final clientName = widget.data['clientName'] ?? 'بدون اسم';
    final invoiceNumber = widget.data['invoiceNumber'] ?? '';
    final date = widget.data['date'] ?? DateTime.now();
    final products =
        widget.data['products'] as List<Map<String, dynamic>>? ?? [];

    double totalBeforeDiscount = 0;
    double totalAfterDiscount = 0;

    for (var product in products) {
      final price = (product['price'] ?? 0).toDouble();
      final qty = (product['quantity'] ?? 1).toDouble();
      final discount = (product['discount'] ?? 0).toDouble();

      final subtotal = price * qty;
      final subtotalAfter = subtotal - (subtotal * discount / 100);

      totalBeforeDiscount += subtotal;
      totalAfterDiscount += subtotalAfter;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("فاتورة"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بيانات الفاتورة
            Text("اسم العميل: $clientName", style: const TextStyle(fontSize: 18)),
            Text("رقم الفاتورة: $invoiceNumber", style: const TextStyle(fontSize: 18)),
            Text("التاريخ: ${date.toString().substring(0, 16)}",
                style: const TextStyle(fontSize: 18)),
            const Divider(thickness: 2),

            // قائمة المنتجات
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final name = product['name'] ?? '';
                  final qty = (product['quantity'] ?? 1).toString();
                  final price = (product['price'] ?? 0).toDouble();
                  final discount = (product['discount'] ?? 0).toDouble();

                  final subtotal = price * (int.tryParse(qty) ?? 1);
                  final subtotalAfter = subtotal - (subtotal * discount / 100);

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("اسم المنتج: $name", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("الكمية: $qty"),
                          Text("السعر للوحدة: $price"),
                          Text("السعر قبل الخصم: $subtotal"),
                          Text("السعر بعد الخصم: $subtotalAfter"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(thickness: 2),

            // الإجماليات
            Text("الإجمالي قبل الخصم: $totalBeforeDiscount",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("الإجمالي بعد الخصم: $totalAfterDiscount",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            // أزرار الحفظ والمشاركة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _savePdf,
                  icon: const Icon(Icons.save),
                  label: const Text("حفظ PDF"),
                ),
                ElevatedButton.icon(
                  onPressed: _sharePdf,
                  icon: const Icon(Icons.share),
                  label: const Text("مشاركة PDF"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}