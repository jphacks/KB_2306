import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:lyricscribe/entities/transcription_segment.dart';

part 'music.g.dart';

@HiveType(typeId: 0)
class Music {
  const Music({
    required this.id,
    required this.audio,
    required this.title,
    required this.segments,
    required this.createdAt,
    required this.updatedAt,
    required this.audioUrl,
    this.artist,
    this.album,
    this.fileName,
  });

  @HiveField(0)
  final String id;
  @HiveField(1)
  final Uint8List audio;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? artist;
  @HiveField(4)
  final String? album;
  @HiveField(5)
  final List<TranscriptionSegment> segments;
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime updatedAt;
  @HiveField(8)
  final String audioUrl;
  @HiveField(9)
  final String? fileName;

  // 1 second padding
  double get end => segments.isEmpty ? 0 : segments.last.end + 8;

  List<double> get segmentStarts => segments.map((e) => e.start).toList();

  List<double> get segmentEnds => segments.map((e) => e.end).toList();

  String get formattedSegments {
    final buffer = StringBuffer()
      ..writeln('[ti:$title]')
      ..writeln('[ar:${artist ?? ''}]')
      ..writeln('[al:${album ?? ''}]')
      ..writeln('[by:]')
      ..writeln('[offset:0]');

    segments.forEach((segment) {
      final startMillis = (segment.start * 1000).toInt();
      final endMillis = (segment.end * 1000).toInt();
      final durationMillis = endMillis - startMillis;

      final wordsBuffer = StringBuffer();
      segment.words.forEach((word) {
        final wordStartMillis = (word.start * 1000).toInt();
        final wordEndMillis = (word.end * 1000).toInt();
        final wordDurationMillis = wordEndMillis - wordStartMillis;
        wordsBuffer
            .write('($wordStartMillis,$wordDurationMillis)${word.word} ');
      });

      buffer.writeln('[$startMillis,$durationMillis]$wordsBuffer');
    });

    return buffer.toString();
  }

  Music copyWith({
    String? id,
    Uint8List? audio,
    String? title,
    String? artist,
    String? album,
    List<TranscriptionSegment>? segments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? audioUrl,
    String? fileName,
  }) =>
      Music(
        id: id ?? this.id,
        audio: audio ?? this.audio,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        album: album ?? this.album,
        segments: segments ?? this.segments,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        audioUrl: audioUrl ?? this.audioUrl,
        fileName: fileName ?? this.fileName,
      );
}
