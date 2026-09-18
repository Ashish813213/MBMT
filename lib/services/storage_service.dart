import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferences] for the small amount of state this
/// prototype keeps on-device between launches - tickets, favourites,
/// emergency contacts, departure reminders and a few settings. No backend,
/// no accounts: this is local-only storage so a demo survives an app
/// restart, not a synced account.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ready() async => _prefs ??= await SharedPreferences.getInstance();

  Future<void> setStringList(String key, List<String> value) async {
    final SharedPreferences p = await _ready();
    await p.setStringList(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    final SharedPreferences p = await _ready();
    return p.getStringList(key) ?? <String>[];
  }

  Future<void> setString(String key, String value) async {
    final SharedPreferences p = await _ready();
    await p.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final SharedPreferences p = await _ready();
    return p.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    final SharedPreferences p = await _ready();
    await p.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final SharedPreferences p = await _ready();
    return p.getBool(key);
  }
}
