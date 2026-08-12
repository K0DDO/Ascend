import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import 'ascend_database.dart';
import 'database_key_storage.dart';
import 'local_content_store.dart';
import 'open_database.dart';

final databaseKeyStorageProvider = Provider<DatabaseKeyStorage>((ref) {
  return DatabaseKeyStorage(ref.watch(secureStorageProvider));
});

final ascendDatabaseProvider = FutureProvider<AscendDatabase>((ref) async {
  final key = await ref.watch(databaseKeyStorageProvider).getOrCreateKey();
  final db = await openAscendDatabase(key);
  ref.onDispose(() => db.close());
  return db;
});

final localContentStoreProvider = FutureProvider<LocalContentStore>((ref) async {
  final db = await ref.watch(ascendDatabaseProvider.future);
  return LocalContentStore(db);
});
