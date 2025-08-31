import 'package:hive/hive.dart';
import 'product_item.dart';
import 'product_variant.dart';

part 'invoice_item.g.dart'; // ملف يتم إنشاؤه تلقائيًا بواسطة build_runner

@HiveType(typeId: 2) // تأكد من أن typeId لا يتعارض مع نماذج أخرى
class InvoiceItem {
  @HiveField(0)
  final ProductItem product;

  @HiveField(1)
  final double pricePerM3;

  @HiveField(2)
  final double volume;

  @HiveField(3) // إضافة حقل جديد
  final double? totalValue;
  @HiveField(4)

  final double? length;
  @HiveField(5)
// قد تكون اختيارية
  final int? quantity;

  double get subtotal => volume * pricePerM3;

  InvoiceItem({
    required this.length,
    required this.quantity,
    required this.product,
    required this.pricePerM3,
    required this.volume,
    this.totalValue,
  });
}
