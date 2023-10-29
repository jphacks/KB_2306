import 'package:hive/hive.dart';

part 'transcription_segment.g.dart';

@HiveType(typeId: 1)
class TranscriptionSegment {
  const TranscriptionSegment({
    required this.word,
    required this.start,
    required this.end,
    required this.words,
  });

  factory TranscriptionSegment.fromMap(Map<String, dynamic> map) =>
      TranscriptionSegment(
        word: map['word'] as String? ?? '',
        start: map['start'] as double,
        end: map['end'] as double,
        words: (map['words'] as List<dynamic>)
            .map((e) => TranscriptionWord.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  @HiveField(0)
  final String word;
  @HiveField(1)
  final double start;
  @HiveField(2)
  final double end;
  @HiveField(3)
  final List<TranscriptionWord> words;
}

@HiveType(typeId: 2)
class TranscriptionWord {
  const TranscriptionWord({
    required this.word,
    required this.start,
    required this.end,
  });

  factory TranscriptionWord.fromMap(Map<String, dynamic> map) =>
      TranscriptionWord(
        word: map['word'] as String? ?? '',
        start: map['start'] as double,
        end: map['end'] as double,
      );

  @HiveField(0)
  final String word;
  @HiveField(1)
  final double start;
  @HiveField(2)
  final double end;
}
