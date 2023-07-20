import 'package:noobcode_flutter_chatapp/constants/strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<LocalStorageService> getInstance() async {
    _preferences ??= await SharedPreferences.getInstance();

    return _instance ??= LocalStorageService();
  }

  dynamic _getFromDisk(String key) {
    var value = _preferences!.get(key);
    return value;
  }

  void _saveToDisk<T>(String key, T content) {
    if (content is String) {
      _preferences!.setString(key, content);
    }
    if (content is bool) {
      _preferences!.setBool(key, content);
    }
    if (content is int) {
      _preferences!.setInt(key, content);
    }
    if (content is double) {
      _preferences!.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences!.setStringList(key, content);
    }
  }

  String? get username => _getFromDisk(USERNAME);

  set username(String? userName) {
    _saveToDisk(USERNAME, userName);
  }
}
