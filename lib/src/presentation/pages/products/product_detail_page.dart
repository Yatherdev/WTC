import 'package:calc_wood/src/presentation/pages/products/product_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../data/hive/hive_services.dart';
import '../../providers/providers.dart';
import '../../../domain/models/product_item.dart';
import '../invoices/invoice_form_page.dart';

// افترض أن لدينا نموذج Client (يجب تعريفه في domain/models/client.dart على سبيل المثال)
class Client {
  final String name;
  final String phone;
  final int? key;

  Client({required this.name, required this.phone, this.key});
}

class ProductDetailPage extends ConsumerStatefulWidget {
  final String hiveKey; // استخدام hiveKey كسلسلة
  const ProductDetailPage({Key? key, required this.hiveKey}) : super(key: key);

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController clientPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final int? parsedKey = int.tryParse(widget.hiveKey);
    if (parsedKey == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('المفتاح غير صالح')),
      );
    }

    final box = Hive.box<ProductItem>(HiveService.productsBox);
    if (!box.isOpen) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('خطأ في تهيئة قاعدة البيانات')),
      );
    }

    final clients = ref.watch(clientsProvider);

    return ValueListenableBuilder(
      valueListenable: box.listenable(keys: [parsedKey]),
      builder: (context, Box<ProductItem> box, child) {
        final product = box.get(parsedKey);
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('خطأ')),
            body: const Center(child: Text('المنتج غير موجود')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/product/edit/${widget.hiveKey}'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('حذف المنتج'),
                      content: Text('هل أنت متأكد من حذف ${product.name}؟'),
                      actions: [
                        TextButton(
                          child: const Text('إلغاء'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child: const Text('حذف'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await box.delete(parsedKey);
                    ref.invalidate(productsProvider);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    title: const Text('اسم المنتج'),
                    subtitle: Text(product.name),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('العرض (م)'),
                    subtitle: Text(product.width.toStringAsFixed(4)),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('السمك/الارتفاع (م)'),
                    subtitle: Text(product.height.toStringAsFixed(4)),
                  ),
                ),
                if (product.directVolume != null)
                  Card(
                    child: ListTile(
                      title: const Text('التكعيب المباشر (م³)'),
                      subtitle: Text(product.directVolume!.toStringAsFixed(4)),
                    ),
                  ),
                Card(
                  child: ListTile(
                    title: const Text('سعر المتر المكعب (ج.م)'),
                    subtitle: Text(product.unitPricePerM3?.toStringAsFixed(2) ?? 'غير محدد'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text('إجمالي الحجم (م³)'),
                    subtitle: Text(product.totalVolume.toStringAsFixed(4)),
                  ),
                ),
                if (product.unitPricePerM3 != null)
                  Card(
                    child: ListTile(
                      title: const Text('القيمة الإجمالية (ج.م)'),
                      subtitle: Text((product.totalVolume * product.unitPricePerM3!).toStringAsFixed(2)),
                    ),
                  ),
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('الأطوال المتعددة', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...product.variants.map(
                        (v) => Card(
                      child: ListTile(
                        title: Text('طول: ${v.length} م'),
                        subtitle: Text('العدد: ${v.quantity}'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Text('بيانات العميل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return clients.map((c) => c.name).where(
                          (option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                    );
                  },
                  onSelected: (String selection) {
                    final selectedClient = clients.firstWhere((c) => c.name == selection);
                    clientNameController.text = selectedClient.name;
                    clientPhoneController.text = selectedClient.phone;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    clientNameController.text = controller.text;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'اسم العميل'),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return clients.map((c) => c.phone).where(
                          (option) => option.contains(textEditingValue.text),
                    );
                  },
                  onSelected: (String selection) {
                    final selectedClient = clients.firstWhere((c) => c.phone == selection);
                    clientNameController.text = selectedClient.name;
                    clientPhoneController.text = selectedClient.phone;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    clientPhoneController.text = controller.text;
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'رقم العميل'),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('تأكيد'),
                  onPressed: () async {
                    final clientName = clientNameController.text.trim();
                    final clientPhone = clientPhoneController.text.trim();

                    if (clientName.isEmpty || clientPhone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال اسم ورقم العميل')),
                      );
                      return;
                    }

                    // التحقق إذا كان العميل موجودًا
                    final existingClient = clients.firstWhere(
                          (c) => c.name == clientName && c.phone == clientPhone,
                      //orElse: () => Client(name: '', phone: ''),
                    );

                    if (existingClient.name.isEmpty) {
                      // إضافة عميل جديد (افترض وجود box للعملاء في HiveService.clientsBox)
                      final clientBox = Hive.box<Client>(HiveService.clientsBox); // افترض تعريف clientsBox
                      final newClient = Client(name: clientName, phone: clientPhone);
                      await clientBox.add(newClient);
                      ref.invalidate(clientsProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إضافة العميل الجديد')),
                      );
                    }

                    // جمع بيانات المنتج والعميل للفاتورة
                    final productData = {
                      "name": product.name,
                      "quantity": 1, // أو احسب بناءً على variants
                      "price": product.unitPricePerM3 ?? 0,
                      "totalVolume": product.totalVolume,
                      // أضف المزيد إذا لزم
                    };

                    final invoiceData = {
                      'clientName': clientName,
                      'clientPhone': clientPhone,
                      'invoiceNumber': DateTime.now().millisecondsSinceEpoch,
                      'date': DateTime.now(),
                      'products': [productData],
                    };

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoiceFormPage(data: invoiceData), // أو InvoicePage حسب الحاجة
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}