import 'package:flutter_firebase/entities/music.dart';
import 'package:flutter_firebase/helpers/indexed_db.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final musicRepositoryProvider = Provider<MusicRepository>(
  (ref) => MusicRepository(databaseHelper: ref.read(databaseHelperProvider)),
);

class MusicRepository {
  const MusicRepository({
    required DatabaseHelper<Music> databaseHelper,
  }) : _databaseHelper = databaseHelper;

  final DatabaseHelper<Music> _databaseHelper;

  Stream<List<Music>> get musicsStream => _databaseHelper.dataStream;

  Future<void> updateTitle(String musicId, String title) async {
    final music = await _databaseHelper.read(musicId);
    if (music == null) {
      throw Exception('Music does not exist.');
    }
    await _databaseHelper.update(musicId, music.copyWith(title: title));
  }
}
