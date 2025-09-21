// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'racha.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RachaAdapter extends TypeAdapter<Racha> {
  @override
  final int typeId = 16;

  @override
  Racha read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Racha(
      id: fields[0] as String,
      nombre: fields[1] as String,
      descripcion: fields[2] as String,
      icono: fields[3] as String,
      rachaActual: fields[4] as int,
      rachaMasAlta: fields[5] as int,
      ultimaVezActualizada: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Racha obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.descripcion)
      ..writeByte(3)
      ..write(obj.icono)
      ..writeByte(4)
      ..write(obj.rachaActual)
      ..writeByte(5)
      ..write(obj.rachaMasAlta)
      ..writeByte(6)
      ..write(obj.ultimaVezActualizada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RachaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
