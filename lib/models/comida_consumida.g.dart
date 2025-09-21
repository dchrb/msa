// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comida_consumida.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComidaConsumidaAdapter extends TypeAdapter<ComidaConsumida> {
  @override
  final int typeId = 17;

  @override
  ComidaConsumida read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComidaConsumida(
      id: fields[0] as String,
      nombre: fields[1] as String,
      calorias: fields[2] as int,
      fecha: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ComidaConsumida obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.calorias)
      ..writeByte(3)
      ..write(obj.fecha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComidaConsumidaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
