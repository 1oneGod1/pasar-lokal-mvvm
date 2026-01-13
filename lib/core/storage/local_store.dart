import 'package:hive_flutter/hive_flutter.dart';

class LocalStore {
  LocalStore(this._box);

  final Box<dynamic> _box;

  static const String defaultBoxName = 'pasar_lokal';

  static Future<LocalStore> open({String boxName = defaultBoxName}) async {
    final box = await Hive.openBox<dynamic>(boxName);
    return LocalStore(box);
  }

  T? read<T>(String key) {
    final value = _box.get(key);
    if (value is T) {
      return value;
    }
    return null;
  }

  Future<void> write(String key, Object? value) {
    return _box.put(key, value);
  }

  Future<void> remove(String key) {
    return _box.delete(key);
  }
}
