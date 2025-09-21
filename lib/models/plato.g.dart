// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plato.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlatoAdapter extends TypeAdapter<Plato> {
  @override
  final int typeId = 4;

  @override
  Plato read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plato(
      id: fields[0] as String,
      tipo: fields[1] as TipoPlato,
      fecha: fields[2] as DateTime,
      alimentos: (fields[3] as List).cast<Alimento>(),
      totalCalorias: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Plato obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipo)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.alimentos)
      ..writeByte(4)
      ..write(obj.totalCalorias);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
