import 'dart:typed_data';

import 'package:flutter_firebase/entities/transcription_segment.dart';
import 'package:hive/hive.dart';

part 'music.g.dart';

String _formatTime(double time) {
  final minutes = time ~/ 60;
  final seconds = time % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(2).padLeft(5, '0')}';
}

@HiveType(typeId: 0)
class Music {
  const Music({
    required this.id,
    required this.audio,
    required this.title,
    required this.segments,
    required this.createdAt,
    required this.updatedAt,
    this.artist,
    this.album,
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

  double get end => segments.isEmpty ? 0 : segments.last.end;

  String get formattedSegments {
    final buffer = StringBuffer()
      ..writeln('[ti:$title]')
      ..writeln('[ar:Unknown Artist]')
      ..writeln('[al:Unknown Album]')
      ..writeln('[by:]')
      ..writeln('[offset:0]')
      ..writeln('[00:00.00]$title');

    segments.forEach((segment) {
      final startTime = _formatTime(segment.start);
      final endTime = _formatTime(segment.end);
      buffer
        ..writeln('[$startTime]')
        ..writeln('[$endTime]${segment.word}');
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
      );
}
