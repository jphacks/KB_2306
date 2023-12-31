import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lyricscribe/entities/music.dart';
import 'package:lyricscribe/entities/transcription_result.dart';
import 'package:lyricscribe/helpers/cloud_functions.dart';
import 'package:lyricscribe/helpers/file_picker.dart';
import 'package:lyricscribe/helpers/hive.dart';
import 'package:lyricscribe/utils/random_string.dart';

final transcriptionRepositoryProvider = Provider<TranscriptionRepository>(
  (ref) => TranscriptionRepository(
    cloudFunctionsHelper: ref.read(cloudFunctionsHelperProvider),
    filePickerHelper: ref.read(filePickerHelperProvider),
    databaseHelper: ref.read(hiveHelperProvider),
  ),
);

class TranscriptionRepository {
  const TranscriptionRepository({
    required CloudFunctionsHelper cloudFunctionsHelper,
    required FilePickerHelper filePickerHelper,
    required HiveHelper databaseHelper,
  })  : _cloudFunctionsHelper = cloudFunctionsHelper,
        _filePickerHelper = filePickerHelper,
        _databaseHelper = databaseHelper;

  final CloudFunctionsHelper _cloudFunctionsHelper;
  final FilePickerHelper _filePickerHelper;
  final HiveHelper _databaseHelper;

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
    if (data['success'] != true) {
      throw Exception('Transcription failed.');
    }

    final transcriptionResult = TranscriptionResult.fromMap(data);

    final id = randomString(20);
    final music = Music(
      id: id,
      audio: bytes,
      title: file.name.substring(0, file.name.lastIndexOf('.')),
      audioUrl: transcriptionResult.url,
      segments: transcriptionResult.segments,
      fileName: file.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _databaseHelper.insert(BoxName.musics, id, music);
  }

  Future<Map<String, dynamic>>? _call(Uint8List bytes) async {
    final result = await _cloudFunctionsHelper.call<Map<String, dynamic>>(
      'transcribe_lyrics',
      parameters: {
        'audio': bytes,
        'fileName': '${randomString(10)}.wav',
      },
      options: HttpsCallableOptions(timeout: const Duration(seconds: 60 * 15)),
    );
    return result.data;
  }
}
