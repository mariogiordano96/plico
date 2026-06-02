import 'package:isar/isar.dart';

part 'body_snapshot.g.dart';

@collection
class BodySnapshot {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime data;

  late double pesoKg;

  double? altezzaCm;

  double? bodyFatManuale;

  String? note;
}
