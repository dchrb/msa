// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SerieAdapter extends TypeAdapter<Serie> {
  @override
  final int typeId = 11;

  @override
  Serie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Serie(
      repeticiones: fields[0] as int,
      pesoKg: fields[1] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Serie obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.repeticiones)
      ..writeByte(1)
      ..write(obj.pesoKg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SerieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
