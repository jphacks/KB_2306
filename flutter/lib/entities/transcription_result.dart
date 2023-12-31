import 'package:lyricscribe/entities/transcription_segment.dart';

class TranscriptionResult {
  const TranscriptionResult({
    required this.success,
    required this.text,
    required this.url,
    required this.segments,
    required this.language,
  });

  factory TranscriptionResult.fromMap(Map<String, dynamic> map) =>
      TranscriptionResult(
        success: map['success'] as bool,
        text: map['text'] as String,
        url: map['url'] as String,
        language: map['language'] as String? ?? '',
        segments: (map['segments'] as List<dynamic>)
            .map((e) => TranscriptionSegment.fromMap(e as Map<String, dynamic>))
            .toList(),
      );

  final bool success;
  final String text;
  final String url;
  final String language;
  final List<TranscriptionSegment> segments;
}
