import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final hiveHelperProvider = Provider<HiveHelper>((ref) => const HiveHelper());

class HiveHelper {
  const HiveHelper();

  Future<Box<T>> _box<T>(BoxName name) async {
    final boxName = name.toString().split('.').last;
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<T>(boxName);
    } else {
      return Hive.openBox<T>(boxName);
    }
  }

  Future<void> insert<T>(BoxName boxName, String key, T value) async {
    final box = await _box<T>(boxName);
    await box.put(key, value);
  }

  Future<T?> read<T>(BoxName boxName, String key) async {
    final box = await _box<T>(boxName);
    return box.get(key);
  }

  Future<void> update<T>(BoxName boxName, String key, T value) async {
    final box = await _box<T>(boxName);
    await box.put(key, value);
  }

  Future<void> delete(BoxName boxName, String key) async {
    final box = await _box(boxName);
    await box.delete(key);
  }

  Stream<List<T>> watch<T>(BoxName boxName) async* {
    final box = await _box<T>(boxName);
    yield box.values.toList();
    yield* box.watch().map((event) => box.values.toList());
  }
}

enum BoxName {
  musics,
}
