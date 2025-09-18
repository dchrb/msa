import 'package:hive/hive.dart';
part 'agua.g.dart';

@HiveType(typeId: 2) // Nuevo typeId
class Agua extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  double amount;
  @HiveField(2)
  final DateTime timestamp;

  Agua({
    required this.id,
    required this.amount,
    required this.timestamp,
  });
}