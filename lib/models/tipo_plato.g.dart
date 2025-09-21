// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_plato.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TipoPlatoAdapter extends TypeAdapter<TipoPlato> {
  @override
  final int typeId = 17;

  @override
  TipoPlato read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TipoPlato.desayuno;
      case 1:
        return TipoPlato.almuerzo;
      case 2:
        return TipoPlato.cena;
      case 3:
        return TipoPlato.snack;
      default:
        return TipoPlato.desayuno;
    }
  }

  @override
  void write(BinaryWriter writer, TipoPlato obj) {
    switch (obj) {
      case TipoPlato.desayuno:
        writer.writeByte(0);
        break;
      case TipoPlato.almuerzo:
        writer.writeByte(1);
        break;
      case TipoPlato.cena:
        writer.writeByte(2);
        break;
      case TipoPlato.snack:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TipoPlatoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
