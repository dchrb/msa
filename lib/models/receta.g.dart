// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecetaAdapter extends TypeAdapter<Receta> {
  @override
  final int typeId = 12;

  @override
  Receta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Receta(
      id: fields[0] as String,
      nombre: fields[1] as String,
      alimentos: (fields[2] as List).cast<Alimento>(),
      pasos: (fields[3] as List).cast<String>(),
      imageUrl: fields[8] as String?,
      totalCalorias: fields[4] as double,
      totalProteinas: fields[5] as double,
      totalCarbohidratos: fields[6] as double,
      totalGrasas: fields[7] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Receta obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.alimentos)
      ..writeByte(3)
      ..write(obj.pasos)
      ..writeByte(4)
      ..write(obj.totalCalorias)
      ..writeByte(5)
      ..write(obj.totalProteinas)
      ..writeByte(6)
      ..write(obj.totalCarbohidratos)
      ..writeByte(7)
      ..write(obj.totalGrasas)
      ..writeByte(8)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecetaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
