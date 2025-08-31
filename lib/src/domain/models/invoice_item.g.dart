// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'invoice_item.dart';

class InvoiceItemAdapter extends TypeAdapter<InvoiceItem> {
  @override
  final int typeId = 2;

  @override
  InvoiceItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceItem(
      product: fields[0] as ProductItem,
      pricePerM3: fields[1] as double,
      volume: fields[2] as double,
      totalValue: fields[3] as double?,
      length: fields[4] as double?,
      quantity: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.pricePerM3)
      ..writeByte(2)
      ..write(obj.volume)
      ..writeByte(3)
      ..write(obj.totalValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
