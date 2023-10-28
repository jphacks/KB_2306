class TranscriptionSegment {
  const TranscriptionSegment({
    required this.word,
    required this.start,
    required this.end,
    required this.words,
  });

  factory TranscriptionSegment.fromMap(Map<String, dynamic> map) =>
      TranscriptionSegment(
        word: map['word'] as String,
        start: map['start'] as double,
        end: map['end'] as double,
        words: (map['words'] as List<dynamic>)
            .map((e) => TranscriptionWord.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  final String word;
  final double start;
  final double end;
  final List<TranscriptionWord> words;
}

class TranscriptionWord {
  const TranscriptionWord({
    required this.word,
    required this.start,
    required this.end,
  });

  factory TranscriptionWord.fromMap(Map<String, dynamic> map) =>
      TranscriptionWord(
        word: map['word'] as String,
        start: map['start'] as double,
        end: map['end'] as double,
      );

  final String word;
  final double start;
  final double end;
}
