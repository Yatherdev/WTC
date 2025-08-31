import 'package:hive/hive.dart';
import 'product_variant.dart';
part 'product_item.g.dart';

@HiveType(typeId: 1)
class ProductItem extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double width; // ثابت أو 0
  @HiveField(2)
  double height; // ثابت أو 0
  @HiveField(3)
  double? unitPricePerM3; // سعر المتر³
  @HiveField(4)
  List<ProductVariant> variants;
  @HiveField(5)
  double? directVolume; // التكعيب مباشر

  ProductItem({
    required this.name,
    this.width = 0,
    this.height = 0,
    this.unitPricePerM3,
    this.variants = const [],
    this.directVolume,
  });

  double get volumeFromVariants {
    if (variants.isEmpty) return 0;
    final base = width * height;
    return variants.fold(0.0, (sum, v) => sum + (base * v.length * v.quantity));
  }

  double get totalVolume => (directVolume ?? 0) + volumeFromVariants;

  double get volumePerPiece {
    if (variants.isNotEmpty) return width * height * variants.first.length;
    return width * height * (directVolume ?? 0);
  }
}