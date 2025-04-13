import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _nameKey = 'user_name';
  static const String _birthDateKey = 'user_birth_date';
  static const String _profileImageKey = 'profile_image_path';
  static const String _retirementAgeKey = 'retirement_age';

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'My name';
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  Future<DateTime?> getBirthDate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_birthDateKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> setBirthDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_birthDateKey, date.millisecondsSinceEpoch);
  }

  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey);
  }

  Future<void> setProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, path);
  }

  Future<int> getRetirementAge() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_retirementAgeKey) ?? 65;
  }

  Future<void> setRetirementAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_retirementAgeKey, age);
  }
}
