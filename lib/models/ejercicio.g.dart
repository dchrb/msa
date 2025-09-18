// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ejercicio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EjercicioAdapter extends TypeAdapter<Ejercicio> {
  @override
  final int typeId = 7;

  @override
  Ejercicio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ejercicio(
      id: fields[0] as String,
      nombre: fields[1] as String,
      tipo: fields[2] as TipoEjercicio,
      musculoPrincipal: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Ejercicio obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.tipo)
      ..writeByte(3)
      ..write(obj.musculoPrincipal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EjercicioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TipoEjercicioAdapter extends TypeAdapter<TipoEjercicio> {
  @override
  final int typeId = 8;

  @override
  TipoEjercicio read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoEjercicio.fuerza;
      case 1:
        return TipoEjercicio.cardio;
      case 2:
        return TipoEjercicio.flexibilidad;
      default:
        return TipoEjercicio.fuerza;
    }
  }

  @override
  void write(BinaryWriter writer, TipoEjercicio obj) {
    switch (obj) {
      case TipoEjercicio.fuerza:
        writer.writeByte(0);
        break;
      case TipoEjercicio.cardio:
        writer.writeByte(1);
        break;
      case TipoEjercicio.flexibilidad:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoEjercicioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
