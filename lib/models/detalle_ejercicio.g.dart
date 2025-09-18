// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalle_ejercicio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetalleEjercicioAdapter extends TypeAdapter<DetalleEjercicio> {
  @override
  final int typeId = 9;

  @override
  DetalleEjercicio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetalleEjercicio(
      ejercicioId: fields[0] as String,
      series: (fields[1] as List).cast<Serie>(),
      duracionMinutos: fields[2] as double?,
      distanciaKm: fields[3] as double?,
      repeticionesSinPeso: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, DetalleEjercicio obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ejercicioId)
      ..writeByte(1)
      ..write(obj.series)
      ..writeByte(2)
      ..write(obj.duracionMinutos)
      ..writeByte(3)
      ..write(obj.distanciaKm)
      ..writeByte(4)
      ..write(obj.repeticionesSinPeso);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetalleEjercicioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
