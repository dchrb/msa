// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insignia.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InsigniaAdapter extends TypeAdapter<Insignia> {
  @override
  final int typeId = 15;

  @override
  Insignia read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Insignia(
      id: fields[0] as String,
      nivelAlcanzado: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Insignia obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nivelAlcanzado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InsigniaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
