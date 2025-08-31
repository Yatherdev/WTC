import 'package:calc_wood/src/presentation/pages/clients/client_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/product_item.dart';
import '../../../domain/models/product_variant.dart';
import '../../providers/providers.dart';
import '../../../domain/models/invoice_item.dart';
import '../../../domain/models/invoice.dart';
import '../../../data/hive/hive_services.dart';
import '../clients/client_form_page.dart';

class InvoiceFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? data;

  const InvoiceFormPage({super.key, this.data});

  @override
  ConsumerState<InvoiceFormPage> createState() => _State();
}

class _State extends ConsumerState<InvoiceFormPage> {
  String? clientId;
  String? clientName; // لعرض اسم العميل المحدد
  PaymentType payType = PaymentType.cash;
  double discount = 0;
  List<InvoiceItem> items = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.data != null && widget.data!['products'] != null) {
      final productsData = widget.data!['products'] as List<dynamic>;
      items = productsData.map((p) {
        try {
          final product = ProductItem(
            name: p['name'] as String? ?? 'منتج غير معروف',
            width: (p['width'] as num?)?.toDouble() ?? 0.0,
            height: (p['height'] as num?)?.toDouble() ?? 0.0,
            directVolume: (p['directVolume'] as num?)?.toDouble(),
            unitPricePerM3: (p['price'] as num?)?.toDouble(),
            variants: (p['variants'] as List<dynamic>? ?? [])
                .map((v) => ProductVariant(
              length: (v['length'] as num?)?.toDouble() ?? 0.0,
              quantity: (v['quantity'] as num?)?.toInt() ?? 1,
            ))
                .toList(),
          );
          return InvoiceItem(
            product: product,
            pricePerM3: (p['price'] as num?)?.toDouble() ?? 0.0,
            volume: (p['totalVolume'] as num?)?.toDouble() ?? 0.0, length: null, quantity: null,
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تحميل بيانات المنتج: $e')),
          );
          return null;
        }
      }).where((item) => item != null).cast<InvoiceItem>().toList();
      discount = (widget.data!['totalAfterDiscount'] as num?)?.toDouble() ?? 0.0;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تم'),
        content: const Text('تم إنشاء الفاتورة بنجاح'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) Navigator.pop(context);
    });
  }

  void _showAllClientsOverlay(BuildContext context, List<Client> clients) {
    // إغلاق أي Overlay مفتوح مسبقًا
    _overlayEntry?.remove();
    _overlayEntry = null;

    // العثور على موقع الحقل النصي
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _overlayEntry?.remove();
                _overlayEntry = null;
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: clients.isEmpty
                    ? const ListTile(
                  title: Text('لا يوجد عملاء، أضف عميلًا جديدًا'),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return ListTile(
                      title: Text(client.name),
                      onTap: () {
                        setState(() {
                          clientId = client.key.toString();
                          clientName = client.name;
                          _controller.text = client.name;
                        });
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);

    final totalBefore = items.fold(0.0, (s, e) => s + e.subtotal);
    final totalAfter = (totalBefore - discount).clamp(0, double.infinity);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء فاتورة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: RawAutocomplete<Client>(
                  textEditingController: _controller,
                  focusNode: _focusNode,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return clients;
                    }
                    return clients.where((client) => client.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()));
                  },
                  displayStringForOption: (Client client) => client.name,
                  fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController controller,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                      ) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'العميل (اختياري)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () => _showAllClientsOverlay(context, clients),
                        ),
                        hintText: clients.isEmpty ? 'لا يوجد عملاء، أضف عميلًا جديدًا' : null,
                      ),
                      onSubmitted: (value) {
                        onFieldSubmitted();
                      },
                      onTap: () {
                        // إغلاق القائمة المنسدلة عند النقر على الحقل
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    );
                  },
                  optionsViewBuilder: (
                      BuildContext context,
                      AutocompleteOnSelected<Client> onSelected,
                      Iterable<Client> options,
                      ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final client = options.elementAt(index);
                              return ListTile(
                                title: Text(client.name),
                                onTap: () => onSelected(client),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  onSelected: (Client client) {
                    setState(() {
                      clientId = client.key.toString();
                      clientName = client.name;
                      _controller.text = client.name;
                    });
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () {
                  showDialog<bool>(
                    context: context,
                    builder: (context) => const ClientFormDialog(),
                  ).then((result) {
                    if (result == true) {
                      ref.invalidate(clientsProvider);
                      _controller.clear(); // إعادة تعيين حقل النص
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<PaymentType>(
            segments: const [
              ButtonSegment(value: PaymentType.cash, label: Text('كاش')),
              ButtonSegment(value: PaymentType.credit, label: Text('آجل')),
            ],
            selected: {payType},
            onSelectionChanged: (s) => setState(() => payType = s.first),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'المنتجات',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Center(
              child: Text(
                'لا توجد منتجات في الفاتورة',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(item.product.name),
                subtitle: Text('حجم: ${item.volume.toStringAsFixed(4)} م³'),
                trailing: Text(item.subtotal.toStringAsFixed(2)),
                leading: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      items.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'خصم (ج.م)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => setState(() => discount = double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(totalBefore.toStringAsFixed(2)),
              trailing: const Text('الإجمالي قبل الخصم'),
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              title: Text(totalAfter.toStringAsFixed(2)),
              trailing: const Text('الإجمالي بعد الخصم'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final invoice = Invoice.tempFrom(
                      items: items,
                      paymentType: payType,
                      discount: discount,
                      clientId: clientId,
                    );
                    final bytes = await generateInvoicePdf(invoice: invoice, shopName: 'متجري');
                    await Printing.layoutPdf(onLayout: (_) async => bytes);
                  },
                  icon: const Icon(Icons.preview),
                  label: const Text('معاينة'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                    if (clientId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى اختيار عميل')),
                      );
                      return;
                    }

                    final invoice = Invoice.tempFrom(
                      items: items,
                      paymentType: payType,
                      discount: discount,
                      clientId: clientId,
                    );

                    final invoiceBox = Hive.box<Invoice>(HiveService.invoicesBox);
                    await invoiceBox.add(invoice);
                    ref.invalidate(invoicesProvider);

                    final bytes = await generateInvoicePdf(
                      invoice: invoice,
                      shopName: 'متجري',
                    );
                    final dir = await getApplicationDocumentsDirectory();
                    final file = File('${dir.path}/invoice.pdf');
                    await file.writeAsBytes(await bytes);
                    await Share.shareXFiles(
                      [XFile(file.path)],
                      text:
                      'فاتورة جديدة للعميل ${clients.firstWhere((c) => c.key.toString() == clientId).name}',
                    );

                    _showSuccessDialog();

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientDetailPage(id: clientId!),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('إنشاء ومشاركة فاتورة'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}