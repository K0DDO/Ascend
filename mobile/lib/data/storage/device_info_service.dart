import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

const _deviceIdKey = 'ascend_device_id';

class DeviceInfoService {
  DeviceInfoService(this._storage);

  final FlutterSecureStorage _storage;
  String? _cachedDeviceId;

  Future<String> deviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    var id = await _storage.read(key: _deviceIdKey);
    if (id == null || id.length < 8) {
      id = const Uuid().v4();
      await _storage.write(key: _deviceIdKey, value: id);
    }
    _cachedDeviceId = id;
    return id;
  }

  String get platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }
}
