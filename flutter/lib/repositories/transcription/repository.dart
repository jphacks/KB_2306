import 'dart:typed_data';

import 'package:flutter_firebase/entities/music.dart';
import 'package:flutter_firebase/entities/transcription_result.dart';
import 'package:flutter_firebase/helpers/cloud_functions.dart';
import 'package:flutter_firebase/helpers/file_picker.dart';
import 'package:flutter_firebase/helpers/indexed_db.dart';
import 'package:flutter_firebase/utils/random_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final transcriptionRepositoryProvider = Provider<TranscriptionRepository>(
  (ref) => TranscriptionRepository(
    cloudFunctionsHelper: ref.read(cloudFunctionsHelperProvider),
    filePickerHelper: ref.read(filePickerHelperProvider),
    databaseHelper: ref.read(databaseHelperProvider),
  ),
);

class TranscriptionRepository {
  const TranscriptionRepository({
    required CloudFunctionsHelper cloudFunctionsHelper,
    required FilePickerHelper filePickerHelper,
    required DatabaseHelper<Music> databaseHelper,
  })  : _cloudFunctionsHelper = cloudFunctionsHelper,
        _filePickerHelper = filePickerHelper,
        _databaseHelper = databaseHelper;

  final CloudFunctionsHelper _cloudFunctionsHelper;
  final FilePickerHelper _filePickerHelper;
  final DatabaseHelper<Music> _databaseHelper;

  Future<void> transcribe() async {
    final file = await _filePickerHelper.pickAudio();
    if (file == null) {
      return; // If canceled, do nothing.
    }
    final bytes = file.bytes;
    if (bytes == null) {
      throw Exception('File bytes is null.');
    }

    final data = await _call(bytes);
    if (data == null) {
      throw Exception('Transcription result is null.');
    }
    final transcriptionResult = TranscriptionResult.fromMap(data);

    final id = randomString(20);
    final music = Music(
      id: id,
      audio: bytes,
      title: file.name,
      segments: transcriptionResult.segments,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _databaseHelper.insert(id, music);
  }

  Future<Map<String, dynamic>>? _call(Uint8List bytes) async {
    final result = await _cloudFunctionsHelper.call<Map<String, dynamic>>(
      'transcribe_lyrics',
      parameters: {
        'audio': bytes,
      },
    );
    return result.data;
  }
}
