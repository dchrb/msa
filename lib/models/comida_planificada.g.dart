// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comida_planificada.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ComidaPlanificadaAdapter extends TypeAdapter<ComidaPlanificada> {
  @override
  final int typeId = 16;

  @override
  ComidaPlanificada read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ComidaPlanificada(
      id: fields[0] as String,
      nombre: fields[1] as String,
      tipo: fields[2] as TipoPlato,
      completado: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ComidaPlanificada obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.completado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComidaPlanificadaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
