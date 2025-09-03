
import 'package:calc_wood/src/domain/models/purchase.dart';
import 'package:hive/hive.dart';

class PurchaseAdapter extends TypeAdapter<Purchase> {
  @override
  final int typeId = 9;

  @override
  Purchase read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Purchase(
      id: fields[0] as String,
      sawType: fields[1] as String,
      thickness: fields[2] as double,
      width: fields[3] as double,
      length: fields[4] as double,
      quantity: fields[5] as int,
      volume: fields[6] as double,
      directVolume: fields[7] as double,
      price: fields[8] as double,
      date: fields[9] as DateTime,
      size: fields[10] as String,
      number: fields[11] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Purchase obj) {
    writer
      ..writeByte(12) // عدد الفيلدات
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sawType)
      ..writeByte(2)
      ..write(obj.thickness)
      ..writeByte(3)
      ..write(obj.width)
      ..writeByte(4)
      ..write(obj.length)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.volume)
      ..writeByte(7)
      ..write(obj.directVolume)
      ..writeByte(8)
      ..write(obj.price)
      ..writeByte(9)
      ..write(obj.date)
      ..writeByte(10)
      ..write(obj.size);
  }
}