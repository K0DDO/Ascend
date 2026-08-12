import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

import 'ascend_database.dart';

Future<void> _configureSqlCipherOnMobile() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
}

Future<AscendDatabase> openAscendDatabase(String passphrase, {bool encrypted = true}) async {
  final useSqlCipher = encrypted && (Platform.isAndroid || Platform.isIOS);

  if (useSqlCipher) {
    await _configureSqlCipherOnMobile();
  }

  final directory = await getApplicationDocumentsDirectory();
  final file = File(p.join(directory.path, 'ascend_encrypted.db'));

  final executor = LazyDatabase(() async {
    if (!encrypted) {
      return NativeDatabase.createInBackground(
        file,
        isolateSetup: _configureSqlCipherOnMobile,
      );
    }
    return NativeDatabase.createInBackground(
      file,
      isolateSetup: _configureSqlCipherOnMobile,
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = '${passphrase.replaceAll("'", "''")}';");
        rawDb.execute('PRAGMA cipher_memory_security = ON;');
      },
    );
  });

  return AscendDatabase(executor);
}

Future<AscendDatabase> openAscendMemoryDatabase() {
  return Future.value(AscendDatabase(NativeDatabase.memory()));
}
