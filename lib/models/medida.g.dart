// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medida.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedidaAdapter extends TypeAdapter<Medida> {
  @override
  final int typeId = 1;

  @override
  Medida read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medida(
      id: fields[0] as String,
      fecha: fields[1] as DateTime,
      peso: fields[2] as double,
      altura: fields[3] as double,
      pecho: fields[4] as double?,
      brazo: fields[5] as double?,
      cintura: fields[6] as double?,
      caderas: fields[7] as double?,
      muslo: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Medida obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fecha)
      ..writeByte(2)
      ..write(obj.peso)
      ..writeByte(3)
      ..write(obj.altura)
      ..writeByte(4)
      ..write(obj.pecho)
      ..writeByte(5)
      ..write(obj.brazo)
      ..writeByte(6)
      ..write(obj.cintura)
      ..writeByte(7)
      ..write(obj.caderas)
      ..writeByte(8)
      ..write(obj.muslo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedidaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
