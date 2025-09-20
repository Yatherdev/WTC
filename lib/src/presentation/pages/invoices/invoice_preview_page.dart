import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../domain/models/invoice.dart';
import '../../../domain/models/client.dart';
import '../../providers/providers.dart';

class InvoicePreviewPage extends ConsumerWidget {
  final Invoice invoice;


  const InvoicePreviewPage({super.key, required this.invoice});

  Future<File> _generatePdf(BuildContext context, String shopName) async {
    final bytes = await generateInvoicePdf(
      invoice: invoice,
      shopName: shopName,
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_${invoice.number}.pdf');
    await file.writeAsBytes(bytes,flush: true); // هنا التعديل
    return file;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clients = ref.watch(clientsProvider);
    final client = clients.firstWhere(
      (c) => c.key.toString() == invoice.clientId,
      orElse: () => Client(name: 'بدون اسم', phone: '', id: ''),
    );
    bool useDirectVolume = false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () async {
    final file = await _generatePdf(context, 'متجري');
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text('تم حفظ الفاتورة في: ${file.path}'),
    ),
    );
    }, icon: Icon(Icons.save)),
          IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_forward))
        ],
        leading: IconButton(onPressed: () async {
          final file = await _generatePdf(context, 'متجري');
          await Share.shareXFiles([
            XFile(file.path),
          ], text: 'فاتورة #${invoice.number} للعميل ${client.name}');
        }, icon: Icon(Icons.upload)),
        title: Text('إيصـال'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Text(
                'شركه الإيمان لإستيراد وتجاره الأخشاب',
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "Cairo-ExtraBold",
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        invoice.isPaid
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: invoice.isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      invoice.isPaid ? 'كــاش' : 'آجــل',
                      style: TextStyle(
                        color:
                            invoice.isPaid
                                ? Colors.green[700]
                                : Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.number,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-Medium",
                  ),
                ),
                Text(
                  ' : رقم الفاتورة',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-SemiBold",
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.date.toString().substring(0, 10),
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-Medium",
                  ),
                ),
                Text(
                  ' : التاريخ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-SemiBold",
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.date.toString().substring(11, 16),
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-Medium",
                  ),
                ),
                Text(
                  ' : الوقت',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-SemiBold",
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  client.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-Medium",
                  ),
                ),
                Text(
                  ' : إسم العميل',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: "Cairo-SemiBold",
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // لو الأعمدة كتيرة
                  child: DataTable(
                    columnSpacing: 25,
                    headingRowColor: WidgetStateProperty.resolveWith((states) {
                      // If the button is pressed, return green, otherwise blue
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.green;
                      }
                      return Colors.black12;
                    }),
                    border: TableBorder.all(),
                    columns: const [
                      DataColumn(label: Text("اسم المنتج")),
                      DataColumn(label: Text("البيان")),
                      DataColumn(label: Text("الطول")),
                      DataColumn(label: Text("العدد")),
                      DataColumn(label: Text("الحجم م³")),
                      DataColumn(label: Text("سعر المتر")),
                      DataColumn(label: Text("القيمه")),
                    ],
                    rows: invoice.items.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item.product.name)),
                          DataCell(Text(item.size.toString())),
                          DataCell(Text(item.product.variants.isNotEmpty ? item.product.variants.first.length.toString() : "-",),),
                          DataCell(Text(item.product.variants.isNotEmpty ? item.product.variants.first.quantity.toString() : "1",),),
                          DataCell(Text(item.volume.toStringAsFixed(4))),
                          DataCell(Text(item.pricePerM3.toStringAsFixed(0))),
                          DataCell(Text(item.subtotal.toStringAsFixed(0))),

                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text(
                invoice.totalBeforeDiscount.toStringAsFixed(0),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                ' : الإجمالي قبل الخصم ',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text(
                invoice.discount.toStringAsFixed(2),
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                ' : الخصم ',
                style: const TextStyle(fontSize: 18),
              ),
            ],),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  invoice.totalAfterDiscount.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' : الإجمالي بعد الخصم ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
            ],),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
