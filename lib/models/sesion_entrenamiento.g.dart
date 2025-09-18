// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sesion_entrenamiento.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SesionEntrenamientoAdapter extends TypeAdapter<SesionEntrenamiento> {
  @override
  final int typeId = 15;

  @override
  SesionEntrenamiento read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SesionEntrenamiento(
      id: fields[0] as String,
      nombre: fields[1] as String,
      fecha: fields[2] as DateTime,
      detalles: (fields[3] as List).cast<DetalleEjercicio>(),
    );
  }

  @override
  void write(BinaryWriter writer, SesionEntrenamiento obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.fecha)
      ..writeByte(3)
      ..write(obj.detalles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SesionEntrenamientoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
