import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _dbKeyStorageKey = 'ascend_db_key';

class DatabaseKeyStorage {
  DatabaseKeyStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(key: _dbKeyStorageKey);
    if (existing != null && existing.length >= 32) {
      return existing;
    }
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64UrlEncode(bytes);
    await _storage.write(key: _dbKeyStorageKey, value: key);
    return key;
  }

  Future<void> destroyKey() async {
    await _storage.delete(key: _dbKeyStorageKey);
  }
}
