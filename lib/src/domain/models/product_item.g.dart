// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductItemAdapter extends TypeAdapter<ProductItem> {
  @override
  final int typeId = 1;

  @override
  ProductItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductItem(
      name: fields[0] as String,
      width: fields[1] as double,
      height: fields[2] as double,
      unitPricePerM3: fields[3] as double?,
      variants: (fields[4] as List).cast<ProductVariant>(),
      directVolume: fields[5] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.width)
      ..writeByte(2)
      ..write(obj.height)
      ..writeByte(3)
      ..write(obj.unitPricePerM3)
      ..writeByte(4)
      ..write(obj.variants)
      ..writeByte(5)
      ..write(obj.directVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
