import 'package:hive/hive.dart';

part 'meta.g.dart';

@HiveType(typeId: 13)
class Meta extends HiveObject {
  @HiveField(0)
  int caloriasObjetivo;

  @HiveField(1)
  int? deficit; // opcional

  Meta({
    required this.caloriasObjetivo,
    this.deficit,
  });
}
