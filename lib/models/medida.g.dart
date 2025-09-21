// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medida.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedidaAdapter extends TypeAdapter<Medida> {
  @override
  final int typeId = 1;

  @override
  Medida read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medida(
      id: fields[0] as String,
      fecha: fields[1] as DateTime,
      tipo: fields[2] as String,
      valor: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Medida obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fecha)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.valor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedidaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
