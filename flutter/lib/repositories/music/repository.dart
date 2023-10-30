import 'package:flutter_firebase/entities/music.dart';
import 'package:flutter_firebase/helpers/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final musicRepositoryProvider = Provider<MusicRepository>(
  (ref) => MusicRepository(databaseHelper: ref.read(hiveHelperProvider)),
);

class MusicRepository {
  const MusicRepository({
    required HiveHelper databaseHelper,
  }) : _databaseHelper = databaseHelper;

  final HiveHelper _databaseHelper;

  Stream<List<Music>> get musicsStream => _databaseHelper.watch(BoxName.musics);

  Future<void> updateTitle(String musicId, String title) async {
    final music = _databaseHelper.read<Music>(BoxName.musics, musicId);
    if (music == null) {
      throw Exception('Music does not exist.');
    }
    await _databaseHelper.update(
      BoxName.musics,
      music.id,
      music.copyWith(title: title),
    );
  }

  Future<void> deleteMusic(String musicId) =>
      _databaseHelper.delete(BoxName.musics, musicId);
}
