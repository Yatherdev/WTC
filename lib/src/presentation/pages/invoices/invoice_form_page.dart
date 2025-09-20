import 'package:calc_wood/src/core/theme/app_theme.dart';
import 'package:calc_wood/src/presentation/Widgets/textForm_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../core/utils/pdf_generator.dart';
import '../../../domain/models/client.dart';
import '../../../domain/models/product_item.dart';
import '../../../domain/models/product_variant.dart';
import '../../../domain/models/invoice_item.dart';
import '../../../domain/models/invoice.dart';
import '../../../data/hive/hive_services.dart';
import '../../providers/providers.dart';
import '../clients/client_form_page.dart';
import 'invoice_page.dart'; // Import InvoicePage

class InvoiceFormPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? data;

  const InvoiceFormPage({super.key, this.data});

  @override
  ConsumerState<InvoiceFormPage> createState() => _State();
}

class _State extends ConsumerState<InvoiceFormPage> {
  final GlobalKey<FormState> productFormKey = GlobalKey<FormState>();
  final TextEditingController sawTypeController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController thicknessController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController directVolumeController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  bool useDirectVolume = false;
  late final GlobalKey<FormState> formKey;

  @override
  void dispose() {
    sawTypeController.dispose();
    sizeController.dispose();
    thicknessController.dispose();
    widthController.dispose();
    lengthController.dispose();
    quantityController.dispose();
    priceController.dispose();
    directVolumeController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  String? clientId;
  String? clientName;
  PaymentType payType = PaymentType.cash;
  double discount = 0;
  List<InvoiceItem> items = [];
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.data != null && widget.data!['products'] != null) {
      final productsData = widget.data!['products'] as List<dynamic>;
      items =
          productsData
              .map((p) {
        try {
          final product = ProductItem(
            name: p['name'] as String? ?? 'منتج غير معروف',
            width: (p['width'] as num?)?.toDouble() ?? 0.0,
            height: (p['height'] as num?)?.toDouble() ?? 0.0,
            directVolume: (p['directVolume'] as num?)?.toDouble(),
            unitPricePerM3: (p['price'] as num?)?.toDouble(),
                    variants:
                        (p['variants'] as List<dynamic>? ?? [])
                            .map(
                              (v) => ProductVariant(
                                length:
                                    (v['length'] as num?)?.toDouble() ?? 0.0,
              quantity: (v['quantity'] as num?)?.toInt() ?? 1,
                              ),
                            )
                .toList(),
          );
          return InvoiceItem(
            product: product,
            pricePerM3: (p['price'] as num?)?.toDouble() ?? 0.0,
            volume: (p['totalVolume'] as num?)?.toDouble() ?? 0.0,
            length: null,
            quantity: null,
            size: '',
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في تحميل بيانات المنتج: $e')),
          );
          return null;
        }
              })
              .where((item) => item != null)
              .cast<InvoiceItem>()
              .toList();
      discount =
          (widget.data!['totalAfterDiscount'] as num?)?.toDouble() ?? 0.0;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
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

  void _clearForm() {
    setState(() {
      // Clear all form fields
      clientId = null;
      payType = PaymentType.cash;
      discount = 0.0;
      items.clear();
      // Clear product input controllers
      sawTypeController.clear();
      sizeController.clear();
      thicknessController.clear();
      widthController.clear();
      lengthController.clear();
      quantityController.clear();
      priceController.clear();
      directVolumeController.clear();

      // Reset form state
      useDirectVolume = false;
    });
  }
  void _showAllClientsOverlay(BuildContext context, List<Client> clients) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    _overlayEntry = OverlayEntry(
      builder:
          (context) => Stack(
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
                    child:
                        clients.isEmpty
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
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);

    // Calculate total for display
    final totalBefore = items.fold(0.0, (s, e) => s + e.subtotal);
    final totalAfter = (totalBefore - discount).clamp(0, double.infinity);

    return Scaffold(
      appBar: AppBar(
          title: const Text('إنشاء فاتورة'),
      centerTitle: true,
      ),
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
                    return clients.where(
                      (client) => client.name.toLowerCase().contains(
                        textEditingValue.text.toLowerCase(),
                      ),
                    );
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
                          onPressed:
                              () => _showAllClientsOverlay(context, clients),
                        ),
                        hintText:
                            clients.isEmpty
                                ? 'لا يوجد عملاء، أضف عميلًا جديدًا'
                                : null,
                      ),
                      onSubmitted: (value) {
                        onFieldSubmitted();
                      },
                      onTap: () {
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
                      _controller.clear();
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
          const SizedBox(height: 8),
          Form(
            key:  productFormKey,
            child: TextFormWidget(
              sawTypeController: sawTypeController,
              thicknessController: thicknessController,
              widthController: widthController,
              lengthController: lengthController,
              quantityController: quantityController,
              directVolumeController: directVolumeController,
              priceController: priceController,
              sizeController: sizeController,
              useDirectVolume: useDirectVolume,
              numberController: numberController,
              onToggleUseDirectVolume: (val) {
                    setState(() {
                  useDirectVolume = val;
                    });
                  },
                ),
              ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'خصم (ج.م)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.sp)),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged:
                (v) => setState(() => discount = double.tryParse(v) ?? 0),
          ),
          SizedBox(height: 12.h),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: FilledButton.icon(
                    onPressed: () async {
                      // Validate the form
                      if (productFormKey.currentState!.validate()) {
                        // Extract values from controllers
                        final sawType = sawTypeController.text;
                        final thickness = double.tryParse(thicknessController.text) ?? 0.0;
                        final width = double.tryParse(widthController.text) ?? 0.0;
                        final length = double.tryParse(lengthController.text) ?? 0.0;
                        final quantity = int.tryParse(quantityController.text) ?? 0;
                        final pricePerM3 = double.tryParse(priceController.text) ?? 0.0;
                        final directVolume = useDirectVolume
                            ? double.tryParse(directVolumeController.text)
                            : null;

                        // Calculate volume if not using direct volume
                        final volume = useDirectVolume
                            ? (directVolume ?? 0.0)
                            : (thickness * width * length * quantity) / 1000000; // Convert to cubic meters

                        // Create a ProductItem
                        final product = ProductItem(
                          name: sawType.isNotEmpty ? sawType : 'منتج غير معروف',
                          width: width,
                          height: thickness,
                          directVolume: directVolume,
                          unitPricePerM3: pricePerM3,
                          variants: [
                            ProductVariant(
                              length: length,
                              quantity: quantity,
                            ),
                          ],
                        );

                        // Create an InvoiceItem
                        final invoiceItem = InvoiceItem(
                          product: product,
                          pricePerM3: pricePerM3,
                          volume: volume,
                          length: length,
                          quantity: quantity,
                          size: sizeController.text.isNotEmpty ? sizeController.text : null,
                        );

                        // Persist InvoiceItem to its Hive box (for history/lookup)
                        try {
                          if (!Hive.isBoxOpen(HiveService.invoiceItemsBox)) {
                            await Hive.openBox<InvoiceItem>(HiveService.invoiceItemsBox);
                          }
                          final invoiceItemsBox = Hive.box<InvoiceItem>(HiveService.invoiceItemsBox);
                          await invoiceItemsBox.add(invoiceItem);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تعذر حفظ عنصر الفاتورة: $e')),
                          );
                        }

                        // Add to in-memory list used for current invoice creation
                        setState(() {
                          items.add(invoiceItem);

                        });
                        // Clear form fields
                        sawTypeController.clear();
                        thicknessController.clear();
                        widthController.clear();
                        lengthController.clear();
                        quantityController.clear();
                        priceController.clear();
                        directVolumeController.clear();
                        sizeController.clear();
                        numberController.clear();


                        setState(() {
                          useDirectVolume = false;
                        });

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إضافة المنتج بنجاح')),
                        );
                      } else {
                        // Show error message if validation fails
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى ملء جميع الحقول بشكل صحيح')),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة منتج'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.green3),
                  ),
                ),
              ),
               SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: FilledButton.icon(
                  onPressed:
                  items.isEmpty
                      ? null
                      : () async {
                    if (clientId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى اختيار عميل'),
                        ),
                      );
                      return;
                    }

                    // Create a proper invoice with unique ID and number
                    final invoiceId = DateTime.now().millisecondsSinceEpoch.toString();
                    final invoiceNumber = (DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(6, '0');

                    final invoice = Invoice(
                      id: invoiceId,
                      number: invoiceNumber,
                      date: DateTime.now(),
                      clientId: clientId,
                      items: items,
                      paymentType: payType,
                      discount: discount,
                      isPaid: payType == PaymentType.cash,
                    );

                    try {
                      if (!Hive.isBoxOpen(HiveService.invoicesBox)) {
                        await Hive.openBox<Invoice>(HiveService.invoicesBox);
                      }
                      final invoiceBox = Hive.box<Invoice>(
                        HiveService.invoicesBox,
                      );
                    await invoiceBox.add(invoice);
                    } catch (e) {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر حفظ الفاتورة: $e')),);
                      return;
                    }
                    // Refresh providers to show updated data
                    ref.invalidate(invoicesProvider);
                    ref.invalidate(clientsProvider);

                    final bytes = await generateInvoicePdf(
                      invoice: invoice,
                      shopName: 'متجري',
                    );
                    final dir =
                    await getApplicationDocumentsDirectory();
                    final file = File('${dir.path}/invoice_${invoice.number}.pdf',);
                    await file.writeAsBytes(bytes);
                    _showSuccessDialog();

                    // Clear form data for new invoice
                    _clearForm();

                    // Navigate to InvoicePage with invoices for the current day (fresh read)
                    if (context.mounted) {
                      final currentDate = DateTime.now();
                      final box = Hive.box<Invoice>(HiveService.invoicesBox);
                      final allInvoices = box.values.toList();
                      final invoicesForToday = allInvoices.where((i) => DateFormat('yyyy-MM-dd').format(i.date) ==
                          DateFormat('yyyy-MM-dd').format(currentDate))
                          .toList();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => InvoicePage(
                            date: currentDate,
                            invoices: invoicesForToday,
                          ),
                        ),
                        (route) => route.isFirst,
                      );
                    }
                  },
                  icon: const Icon(Icons.file_download),
                  label: const Text('إنشاء الفاتورة'),
                  style: FilledButton.styleFrom(backgroundColor:AppColors.green3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
