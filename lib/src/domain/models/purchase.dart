import 'package:hive/hive.dart';

@HiveType(typeId: 9)
class Purchase {
  @HiveField(0)
  String? key;
  @HiveField(1)
  final String id;
  @HiveField(2)
  final String sawType;
  @HiveField(3)
  final double thickness;
  @HiveField(4)
  final double width;
  @HiveField(5)
  final double length;
  @HiveField(6)
  final int quantity;
  @HiveField(7)
  final double volume;
  @HiveField(8)
  final double directVolume;
  @HiveField(9)
  final double price;
  @HiveField(10)
  final DateTime date;
  @HiveField(11)
  final String size;

  Purchase({
    this.key,
    required this.id,
    required this.sawType,
    required this.thickness,
    required this.width,
    required this.length,
    required this.quantity,
    required this.volume,
    required this.directVolume,
    required this.price,
    required this.date,
    required this.size,
  });
}