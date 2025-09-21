import 'package:hive/hive.dart';

part 'serie.g.dart';

@HiveType(typeId: 11)
class Serie extends HiveObject {
  @HiveField(0)
  int repeticiones;

  @HiveField(1)
  double? pesoKg;

  Serie({
    required this.repeticiones,
    this.pesoKg,
  });

  Map<String, dynamic> toJson() => {
        'repeticiones': repeticiones,
        'pesoKg': pesoKg,
      };

  factory Serie.fromJson(Map<String, dynamic> json) => Serie(
        repeticiones: json['repeticiones'],
        pesoKg: json['pesoKg']?.toDouble(),
      );
}
