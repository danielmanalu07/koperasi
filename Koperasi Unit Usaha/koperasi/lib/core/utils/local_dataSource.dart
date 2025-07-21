import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDatasource {
  Future<void> setToken(String token);
  Future<String?> getToken();
  Future<void> removeToken();
}

class LocalDatasourceImpl implements LocalDatasource {
  static const String _keyToken = 'user_token';

  final SharedPreferences sharedPreferences;

  LocalDatasourceImpl(this.sharedPreferences);

  @override
  Future<String?> getToken() {
    return Future.value(sharedPreferences.getString(_keyToken));
  }

  @override
  Future<void> removeToken() {
    return sharedPreferences.remove(_keyToken);
  }

  @override
  Future<void> setToken(String token) {
    return sharedPreferences.setString(_keyToken, token);
  }
}
