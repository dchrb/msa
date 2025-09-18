// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alimento.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlimentoAdapter extends TypeAdapter<Alimento> {
  @override
  final int typeId = 3;

  @override
  Alimento read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Alimento(
      id: fields[0] as String?,
      nombre: fields[1] as String,
      calorias: fields[2] as double,
      proteinas: fields[3] as double,
      carbohidratos: fields[4] as double,
      grasas: fields[5] as double,
      porcionGramos: fields[6] as double,
      idApi: fields[7] as String?,
      esManual: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Alimento obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.calorias)
      ..writeByte(3)
      ..write(obj.proteinas)
      ..writeByte(4)
      ..write(obj.carbohidratos)
      ..writeByte(5)
      ..write(obj.grasas)
      ..writeByte(6)
      ..write(obj.porcionGramos)
      ..writeByte(7)
      ..write(obj.idApi)
      ..writeByte(8)
      ..write(obj.esManual);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlimentoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
