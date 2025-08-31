import 'package:hive/hive.dart';
part 'product_variant.g.dart';

@HiveType(typeId: 2)
class ProductVariant extends HiveObject {
  @HiveField(0)
  double length;
  @HiveField(1)
  int quantity;

  ProductVariant({required this.length, required this.quantity});
}