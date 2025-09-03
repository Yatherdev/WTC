import 'package:hive/hive.dart';

@HiveType(typeId: 9)
class Purchase extends HiveObject { // ✅ خلي الموديل يورث HiveObject
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sawType;

  @HiveField(2)
  final double thickness;

  @HiveField(3)
  final double width;

  @HiveField(4)
  final double length;

  @HiveField(5)
  final int quantity;

  @HiveField(6)
  final double volume;

  @HiveField(7)
  final double directVolume;

  @HiveField(8)
  final double price;

  @HiveField(9)
  final DateTime date;

  @HiveField(10)
  final String size;

  @HiveField(11)
  final double number;

  Purchase({
    required this.number,
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