// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recordatorio.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordatorioAdapter extends TypeAdapter<Recordatorio> {
  @override
  final int typeId = 0;

  @override
  Recordatorio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Recordatorio(
      id: fields[0] as String,
      hora: fields[1] as int,
      minuto: fields[2] as int,
      mensaje: fields[3] as String,
      activado: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Recordatorio obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.hora)
      ..writeByte(2)
      ..write(obj.minuto)
      ..writeByte(3)
      ..write(obj.mensaje)
      ..writeByte(4)
      ..write(obj.activado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordatorioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
