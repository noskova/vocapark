import 'package:hive/hive.dart';

part 'word_to_learn.g.dart';

@HiveType(typeId: 1)
class WordToLearn extends HiveObject {
  @HiveField(0)
  late String? word;
  @HiveField(1)
  late String? translation;
  @HiveField(2)
  late DateTime? date;
  @HiveField(3)
  late int? wordScore;
}
