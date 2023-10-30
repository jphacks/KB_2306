import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final hiveHelperProvider = Provider<HiveHelper>((ref) => HiveHelper());

enum BoxName {
  musics,
}

final Map<BoxName, Box> _boxMap = {};

Future<void> openBox<T>(BoxName boxName) async {
  final name = boxName.toString().split('.').last;
  if (!_boxMap.containsKey(boxName)) {
    final box = await Hive.openBox<T>(name);
    _boxMap[boxName] = box;
  }
}

Box<T> box<T>(BoxName boxName) {
  if (!_boxMap.containsKey(boxName)) {
    throw Exception('Box not found: $boxName');
  }
  return _boxMap[boxName]! as Box<T>;
}

class HiveHelper {
  HiveHelper();

  Future<void> insert<T>(BoxName boxName, String key, T value) async {
    await box<T>(boxName).put(key, value);
  }

  T? read<T>(BoxName boxName, String key) => box<T>(boxName).get(key);

  Future<void> update<T>(BoxName boxName, String key, T value) async {
    await box<T>(boxName).put(key, value);
  }

  Future<void> delete<T>(BoxName boxName, String key) async {
    await box<T>(boxName).delete(key);
  }

  Stream<List<T>> watch<T>(BoxName boxName) async* {
    final b = box<T>(boxName);
    yield b.values.toList();
    yield* b.watch().map((event) => b.values.toList());
  }
}
