import 'package:hive/hive.dart';

part 'profile.g.dart';

@HiveType(typeId: 10)
enum Sexo {
  @HiveField(0)
  masculino,
  @HiveField(1)
  femenino,
}

@HiveType(typeId: 11)
enum NivelActividad {
  @HiveField(0)
  sedentario,
  @HiveField(1)
  ligero,
  @HiveField(2)
  moderado,
  @HiveField(3)
  activo,
  @HiveField(4)
  muyActivo,
}

@HiveType(typeId: 9)
class Profile extends HiveObject {
  @HiveField(0)
  String? imagePath;

  @HiveField(1)
  String name;

  @HiveField(2)
  int age;

  @HiveField(3)
  double height;

  @HiveField(4)
  double currentWeight;

  @HiveField(5)
  Sexo sex;

  @HiveField(6)
  NivelActividad activityLevel;

  @HiveField(7)
  double calorieGoal;

  @HiveField(8)
  double? weightGoal; // NUEVO CAMPO

  Profile({
    required this.name,
    required this.age,
    required this.height,
    required this.currentWeight,
    required this.sex,
    required this.activityLevel,
    this.imagePath,
    this.calorieGoal = 2000.0,
    this.weightGoal, // NUEVO CAMPO
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'height': height,
        'currentWeight': currentWeight,
        'sex': sex.index,
        'activityLevel': activityLevel.index,
        'imagePath': imagePath,
        'calorieGoal': calorieGoal,
        'weightGoal': weightGoal, // NUEVO CAMPO
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: json['name'] ?? '',
        age: json['age'] ?? 0,
        height: (json['height'] ?? 0.0).toDouble(),
        currentWeight: (json['currentWeight'] ?? 0.0).toDouble(),
        sex: Sexo.values[json['sex'] ?? 0],
        activityLevel: NivelActividad.values[json['activityLevel'] ?? 0],
        imagePath: json['imagePath'],
        calorieGoal: (json['calorieGoal'] ?? 2000.0).toDouble(),
        weightGoal: (json['weightGoal'])?.toDouble(), // NUEVO CAMPO
      );

  Profile copyWith({
    String? name,
    int? age,
    double? height,
    double? currentWeight,
    Sexo? sex,
    NivelActividad? activityLevel,
    String? imagePath,
    double? calorieGoal,
    double? weightGoal, // NUEVO CAMPO
  }) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      sex: sex ?? this.sex,
      activityLevel: activityLevel ?? this.activityLevel,
      imagePath: imagePath ?? this.imagePath,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      weightGoal: weightGoal ?? this.weightGoal, // NUEVO CAMPO
    );
  }
}
