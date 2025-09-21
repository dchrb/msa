import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'alimento.g.dart';

@HiveType(typeId: 3)
class Alimento extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  double calorias;

  @HiveField(3)
  double proteinas;

  @HiveField(4)
  double carbohidratos;

  @HiveField(5)
  double grasas;

  @HiveField(6)
  double porcionGramos;

  @HiveField(7)
  String? idApi;

  @HiveField(8)
  bool esManual;

  Alimento({
    String? id,
    required this.nombre,
    this.calorias = 0.0,
    this.proteinas = 0.0,
    this.carbohidratos = 0.0,
    this.grasas = 0.0,
    this.porcionGramos = 100.0,
    this.idApi,
    this.esManual = false,
  }) : id = id ?? const Uuid().v4();

  Alimento copyWith({
    String? id,
    String? nombre,
    double? calorias,
    double? proteinas,
    double? carbohidratos,
    double? grasas,
    double? porcionGramos,
    String? idApi,
    bool? esManual,
  }) {
    return Alimento(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      calorias: calorias ?? this.calorias,
      proteinas: proteinas ?? this.proteinas,
      carbohidratos: carbohidratos ?? this.carbohidratos,
      grasas: grasas ?? this.grasas,
      porcionGramos: porcionGramos ?? this.porcionGramos,
      idApi: idApi ?? this.idApi,
      esManual: esManual ?? this.esManual,
    );
  }

  // Convierte el objeto Alimento a un Map para Firestore
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'calorias': calorias,
        'proteinas': proteinas,
        'carbohidratos': carbohidratos,
        'grasas': grasas,
        'porcionGramos': porcionGramos,
        'idApi': idApi,
        'esManual': esManual,
      };

  // Crea un objeto Alimento desde un Map (útil al leer de Firestore)
  factory Alimento.fromJson(Map<String, dynamic> json) => Alimento(
        id: json['id'],
        nombre: json['nombre'],
        calorias: json['calorias']?.toDouble() ?? 0.0,
        proteinas: json['proteinas']?.toDouble() ?? 0.0,
        carbohidratos: json['carbohidratos']?.toDouble() ?? 0.0,
        grasas: json['grasas']?.toDouble() ?? 0.0,
        porcionGramos: json['porcionGramos']?.toDouble() ?? 100.0,
        idApi: json['idApi'],
        esManual: json['esManual'] ?? false,
      );
}
