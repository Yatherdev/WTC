
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
      key: fields[0] as String?,
      id: fields[1] as String,
      sawType: fields[2] as String,
      thickness: fields[3] as double,
      width: fields[4] as double,
      length: fields[5] as double,
      quantity: fields[6] as int,
      volume: fields[7] as double,
      directVolume: fields[8] as double,
      price: fields[9] as double,
      date: fields[10] as DateTime,
      size: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Purchase obj) {
    writer
      ..writeByte(12) // Number of fields
      ..writeByte(0)
      ..write(obj.key)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.sawType)
      ..writeByte(3)
      ..write(obj.thickness)
      ..writeByte(4)
      ..write(obj.width)
      ..writeByte(5)
      ..write(obj.length)
      ..writeByte(6)
      ..write(obj.quantity)
      ..writeByte(7)
      ..write(obj.volume)
      ..writeByte(8)
      ..write(obj.directVolume)
      ..writeByte(9)
      ..write(obj.price)
      ..writeByte(10)
      ..write(obj.date)
      ..writeByte(11)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PurchaseAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}