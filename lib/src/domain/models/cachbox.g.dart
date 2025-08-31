
import 'package:hive/hive.dart';

import 'cachbox.dart';

class CashboxAdapter extends TypeAdapter<Cashbox> {
  @override
  final int typeId = 10; // Changed to 10 to avoid conflict with Client (typeId: 3)

  @override
  Cashbox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cashbox(
      balance: fields[0] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Cashbox obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CashboxAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}