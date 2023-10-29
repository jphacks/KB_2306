// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription_segment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranscriptionSegmentAdapter extends TypeAdapter<TranscriptionSegment> {
  @override
  final int typeId = 1;

  @override
  TranscriptionSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranscriptionSegment(
      word: fields[0] as String,
      start: fields[1] as double,
      end: fields[2] as double,
      words: (fields[3] as List).cast<TranscriptionWord>(),
    );
  }

  @override
  void write(BinaryWriter writer, TranscriptionSegment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end)
      ..writeByte(3)
      ..write(obj.words);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TranscriptionWordAdapter extends TypeAdapter<TranscriptionWord> {
  @override
  final int typeId = 2;

  @override
  TranscriptionWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranscriptionWord(
      word: fields[0] as String,
      start: fields[1] as double,
      end: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TranscriptionWord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.start)
      ..writeByte(2)
      ..write(obj.end);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
