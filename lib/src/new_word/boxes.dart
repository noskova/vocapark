import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/word_to_learn.dart';

class Boxes {
  static Box<WordToLearn> getVocabulary() =>
      Hive.box<WordToLearn>('vocabulary');
}
