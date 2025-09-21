// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_ejercicio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipoEjercicioAdapter extends TypeAdapter<TipoEjercicio> {
  @override
  final int typeId = 13;

  @override
  TipoEjercicio read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoEjercicio.fuerza;
      case 1:
        return TipoEjercicio.cardio;
      case 2:
        return TipoEjercicio.flexibilidad;
      case 3:
        return TipoEjercicio.equilibrio;
      case 4:
        return TipoEjercicio.otro;
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
      case TipoEjercicio.equilibrio:
        writer.writeByte(3);
        break;
      case TipoEjercicio.otro:
        writer.writeByte(4);
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
