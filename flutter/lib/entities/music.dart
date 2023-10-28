import 'dart:typed_data';

import 'package:flutter_firebase/entities/transcription_segment.dart';

String _formatTime(double time) {
  final minutes = time ~/ 60;
  final seconds = time % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toStringAsFixed(2).padLeft(5, '0')}';
}

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

  final String id;
  final Uint8List audio;
  final String title;
  final String? artist;
  final String? album;
  final List<TranscriptionSegment> segments;
  final DateTime createdAt;
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
