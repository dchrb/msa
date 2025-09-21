// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 9;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      name: fields[1] as String,
      age: fields[2] as int,
      height: fields[3] as double,
      currentWeight: fields[4] as double,
      sex: fields[5] as Sexo,
      activityLevel: fields[6] as NivelActividad,
      imagePath: fields[0] as String?,
      calorieGoal: fields[7] as double,
      weightGoal: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.imagePath)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.height)
      ..writeByte(4)
      ..write(obj.currentWeight)
      ..writeByte(5)
      ..write(obj.sex)
      ..writeByte(6)
      ..write(obj.activityLevel)
      ..writeByte(7)
      ..write(obj.calorieGoal)
      ..writeByte(8)
      ..write(obj.weightGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SexoAdapter extends TypeAdapter<Sexo> {
  @override
  final int typeId = 10;

  @override
  Sexo read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Sexo.masculino;
      case 1:
        return Sexo.femenino;
      default:
        return Sexo.masculino;
    }
  }

  @override
  void write(BinaryWriter writer, Sexo obj) {
    switch (obj) {
      case Sexo.masculino:
        writer.writeByte(0);
        break;
      case Sexo.femenino:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SexoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NivelActividadAdapter extends TypeAdapter<NivelActividad> {
  @override
  final int typeId = 11;

  @override
  NivelActividad read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NivelActividad.sedentario;
      case 1:
        return NivelActividad.ligero;
      case 2:
        return NivelActividad.moderado;
      case 3:
        return NivelActividad.activo;
      case 4:
        return NivelActividad.muyActivo;
      default:
        return NivelActividad.sedentario;
    }
  }

  @override
  void write(BinaryWriter writer, NivelActividad obj) {
    switch (obj) {
      case NivelActividad.sedentario:
        writer.writeByte(0);
        break;
      case NivelActividad.ligero:
        writer.writeByte(1);
        break;
      case NivelActividad.moderado:
        writer.writeByte(2);
        break;
      case NivelActividad.activo:
        writer.writeByte(3);
        break;
      case NivelActividad.muyActivo:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NivelActividadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
