import 'dart:async';

import 'package:flutter_firebase/entities/music.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:idb_shim/idb_client.dart';

// TODO: Helper が Entity に依存しているのを解消
final databaseHelperProvider = Provider((ref) => DatabaseHelper<Music>());

class DatabaseHelper<T extends Object> {
  DatabaseHelper() {
    if (!IdbFactory.supported) {
      throw Exception('IndexedDB is not supported');
    }
    final idbFactory = getIdbFactory();
    if (idbFactory == null) {
      throw Exception('IndexedDB is not supported');
    }
    Future.microtask(() async {
      _db = await idbFactory.open(
        databaseName,
        version: _version,
        onUpgradeNeeded: (event) => event.database.createObjectStore(
          storeName,
          autoIncrement: true,
        ),
      );
      await _loadData();
    });
  }

  static const _version = 1;
  static const databaseName = 'lyrics_transcriber';
  static const storeName = 'musics';

  late final Database _db;

  final _controller = StreamController<List<T>>.broadcast();
  Stream<List<T>> get dataStream => _controller.stream;

  Future<void> _loadData() async {
    final transaction = _db.transaction(storeName, idbModeReadOnly);
    final store = transaction.objectStore(storeName);
    final records = await store.getAll();
    _controller.add(records as List<T>);
  }

  Future<void> insert(String key, T value) async {
    final transaction = _db.transaction(storeName, idbModeReadWrite);
    final store = transaction.objectStore(storeName);
    await store.put(value, key);
    await _loadData();
  }

  Future<T?> read(String key) async {
    final transaction = _db.transaction(storeName, idbModeReadOnly);
    final store = transaction.objectStore(storeName);
    final obj = (await store.getObject(key)) as T?;
    return obj;
  }

  Future<void> update(String key, T newValue) async {
    final transaction = _db.transaction(storeName, idbModeReadWrite);
    final store = transaction.objectStore(storeName);
    await store.put(newValue, key);
    await _loadData();
  }

  Future<void> delete(String key) async {
    final transaction = _db.transaction(storeName, idbModeReadWrite);
    final store = transaction.objectStore(storeName);
    await store.delete(key);
    await _loadData();
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
