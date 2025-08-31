import 'package:hive/hive.dart';

import '../../domain/models/product_item.dart';
import '../hive/hive_services.dart';

class ProductRepository {
  final box = Hive.box<ProductItem>(HiveService.productsBox);
  List<ProductItem> getAll() => box.values.toList();
  Future<void> add(ProductItem item) => box.add(item);
  Future<void> update(ProductItem item) => item.save();
  Future<void> delete(ProductItem item) => item.delete();
}