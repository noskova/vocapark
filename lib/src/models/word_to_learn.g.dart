// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_to_learn.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordToLearnAdapter extends TypeAdapter<WordToLearn> {
  @override
  final int typeId = 1;

  @override
  WordToLearn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordToLearn()
      ..word = fields[0] as String?
      ..translation = fields[1] as String?
      ..date = fields[2] as DateTime?
      ..wordScore = fields[3] as int?;
  }

  @override
  void write(BinaryWriter writer, WordToLearn obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.translation)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.wordScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordToLearnAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
