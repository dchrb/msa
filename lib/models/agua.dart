import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
part 'agua.g.dart';

@HiveType(typeId: 2)
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory Agua.fromJson(Map<String, dynamic> json) => Agua(
        id: json['id'],
        amount: json['amount']?.toDouble(),
        timestamp: (json['timestamp'] as Timestamp).toDate(),
      );

  Agua copyWith({double? amount}) {
    return Agua(
      id: id,
      amount: amount ?? this.amount,
      timestamp: timestamp,
    );
  }
}
