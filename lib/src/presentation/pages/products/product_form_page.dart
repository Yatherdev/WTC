import 'package:calc_wood/src/presentation/pages/invoices/invoice_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../data/hive/hive_services.dart';
import '../../../domain/models/product_item.dart';
import '../../../domain/models/product_variant.dart';
import '../../providers/providers.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  final String? hiveKey;

  const ProductFormPage({super.key, this.hiveKey});

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final name = TextEditingController();
  final width = TextEditingController();
  final height = TextEditingController();
  final directVolume = TextEditingController();
  final price = TextEditingController();
  final lenCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  bool isDirectVolume = false;

  List<ProductVariant> variants = [];
  ProductItem? editingProduct;
  double totalVolume = 0.0;
  double? totalValue;

  @override
  void initState() {
    super.initState();
    if (widget.hiveKey != null) {
      final parsedKey = int.tryParse(widget.hiveKey!);
      if (parsedKey != null) {
        final box = Hive.box<ProductItem>(HiveService.productsBox);
        editingProduct = box.get(parsedKey);
        if (editingProduct != null) {
          name.text = editingProduct!.name;
          width.text = editingProduct!.width.toString();
          height.text = editingProduct!.height.toString();
          directVolume.text = editingProduct!.directVolume?.toStringAsFixed(2) ?? '';
          price.text = editingProduct!.unitPricePerM3?.toStringAsFixed(2) ?? '';
          variants = List<ProductVariant>.from(editingProduct!.variants);
          isDirectVolume = editingProduct!.directVolume != null;
          _recalculate();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مفتاح المنتج غير صالح')),
        );
      }
    }
  }

  ProductItem? _buildProduct() {
    try {
      return ProductItem(
        name: name.text,
        width: isDirectVolume ? 0 : (double.tryParse(width.text) ?? 0),
        height: isDirectVolume ? 0 : (double.tryParse(height.text) ?? 0),
        directVolume: isDirectVolume ? (double.tryParse(directVolume.text) ?? 0) : null,
        unitPricePerM3: double.tryParse(price.text),
        variants: isDirectVolume ? [] : variants,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في إدخال البيانات: $e')),
      );
      return null;
    }
  }

  void _recalculate() {
    double volume = 0.0;
    if (!isDirectVolume) {
      for (var v in variants) {
        final widthCm = double.tryParse(width.text) ?? 0;
        final heightCm = double.tryParse(height.text) ?? 0;
        final volumeM3 = (widthCm / 100) * (heightCm / 100) * v.length * v.quantity;
        volume += volumeM3;
      }
      final len = double.tryParse(lenCtrl.text) ?? 0;
      final qty = int.tryParse(qtyCtrl.text) ?? 1;
      if (len > 0 && qty > 0) {
        final widthCm = double.tryParse(width.text) ?? 0;
        final heightCm = double.tryParse(height.text) ?? 0;
        final currentVolumeM3 = (widthCm / 100) * (heightCm / 100) * len * qty;
        volume += currentVolumeM3;
      }
    } else {
      volume = double.tryParse(directVolume.text) ?? 0;
    }

    double? value;
    if (price.text.isNotEmpty) {
      value = volume * (double.tryParse(price.text) ?? 0);
    }

    setState(() {
      totalVolume = volume;
      totalValue = value;
    });
  }

  void _clearForm() {
    name.clear();
    width.clear();
    height.clear();
    directVolume.clear();
    price.clear();
    lenCtrl.clear();
    qtyCtrl.text = '1';
    variants.clear();
    setState(() {
      totalVolume = 0.0;
      totalValue = null;
      isDirectVolume = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hiveKey == null ? 'إضافة منتج' : 'تعديل المنتج'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'اسم المنتج',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إدخال الحجم مباشرة',
                  style: TextStyle(fontSize: 16),
                ),
                Switch(
                  value: isDirectVolume,
                  onChanged: (value) {
                    setState(() {
                      isDirectVolume = value;
                      if (value) {
                        width.clear();
                        height.clear();
                        lenCtrl.clear();
                        qtyCtrl.text = '1';
                        variants.clear();
                      } else {
                        directVolume.clear();
                      }
                      _recalculate();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isDirectVolume) ...[
              TextField(
                controller: width,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'العرض (سم)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _recalculate(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: height,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السمك (سم)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _recalculate(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: lenCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الطول (م)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الكمية',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => _recalculate(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final len = double.tryParse(lenCtrl.text) ?? 0;
                      final qty = int.tryParse(qtyCtrl.text) ?? 1;
                      if (len > 0 && qty > 0) {
                        setState(() {
                          variants.add(ProductVariant(length: len, quantity: qty));
                          lenCtrl.clear();
                          qtyCtrl.text = '1';
                          _recalculate();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى إدخال طول وكمية صالحين')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (variants.isNotEmpty) ...[
                const Text(
                  'الأطوال المضافة:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...variants.asMap().entries.map((entry) {
                  final index = entry.key;
                  final variant = entry.value;
                  return ListTile(
                    title: Text('طول: ${variant.length} م, كمية: ${variant.quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          variants.removeAt(index);
                          _recalculate();
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ],
            if (isDirectVolume)
              TextField(
                controller: directVolume,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الحجم (م³)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _recalculate(),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'سعر المتر المكعب',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalculate(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "إجمالي التكعيب: ${totalVolume.toStringAsFixed(2)} م³",
                  style: const TextStyle(fontSize: 16),
                ),
                if (totalValue != null)
                  Text(
                    "إجمالي السعر: ${totalValue!.toStringAsFixed(2)} ج.م",
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Save & Back"),
                    onPressed: () async {
                      final product = _buildProduct();
                      if (product == null) return;

                      final box = Hive.box<ProductItem>(HiveService.productsBox);
                      if (widget.hiveKey == null) {
                        await box.add(product);
                      } else {
                        await box.put(int.parse(widget.hiveKey!), product);
                      }

                      ref.invalidate(productsProvider);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_as),
                    label: const Text("Save & Stay"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    onPressed: () async {
                      final product = _buildProduct();
                      if (product == null) return;

                      final box = Hive.box<ProductItem>(HiveService.productsBox);
                      if (widget.hiveKey == null) {
                        await box.add(product);
                      } else {
                        await box.put(int.parse(widget.hiveKey!), product);
                      }

                      ref.invalidate(productsProvider);
                      _clearForm();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("إنشاء فاتورة"),
                    onPressed: () async {
                      final product = _buildProduct();
                      if (product == null) return;

                      final box = Hive.box<ProductItem>(HiveService.productsBox);
                      String key;
                      if (widget.hiveKey == null) {
                        key = (await box.add(product)).toString();
                      } else {
                        final parsedKey = int.parse(widget.hiveKey!);
                        await box.put(parsedKey, product);
                        key = parsedKey.toString();
                      }

                      final len = double.tryParse(lenCtrl.text) ?? 0;
                      final qty = int.tryParse(qtyCtrl.text) ?? 1;
                      if (!isDirectVolume && len > 0 && qty > 0) {
                        variants.add(ProductVariant(length: len, quantity: qty));
                      }

                      ref.invalidate(productsProvider);

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceFormPage(
                              data: {
                                'products': [
                                  {
                                    'name': product.name,
                                    'width': product.width,
                                    'height': product.height,
                                    'directVolume': product.directVolume,
                                    'price': product.unitPricePerM3,
                                    'variants': isDirectVolume
                                        ? []
                                        : variants
                                        .map((v) => {
                                      'length': v.length,
                                      'quantity': v.quantity,
                                    })
                                        .toList(),
                                    'totalVolume': totalVolume,
                                    'totalValue': totalValue,
                                  },
                                ],
                                'totalAfterDiscount': totalValue ?? 0.0,
                              },
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}