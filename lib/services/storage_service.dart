import 'package:shared_preferences/shared_preferences.dart';

// This saves stuff on your phone so you don't lose it
class StorageService {
  // Keys are like labels on boxes where we store things
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _totalXpKey = 'total_xp';
  static const String _questsCompletedKey = 'quests_completed';
  static const String _lastQuestDateKey = 'last_quest_date';

  // Save your ID (like your name tag)
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get your ID back
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> saveTotalXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalXpKey, xp);
  }

  Future<int> getTotalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalXpKey) ?? 0;
  }

  Future<void> saveQuestsCompleted(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_questsCompletedKey, count);
  }

  Future<int> getQuestsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_questsCompletedKey) ?? 0;
  }

  Future<bool> hasCompletedTodayQuest() async {
    final prefs = await SharedPreferences.getInstance();
    final lastQuestDate = prefs.getString(_lastQuestDateKey);
    
    if (lastQuestDate == null) return false;
    
    final lastDate = DateTime.parse(lastQuestDate);
    final today = DateTime.now();
    
    return lastDate.year == today.year &&
           lastDate.month == today.month &&
           lastDate.day == today.day;
  }

  Future<void> markTodayQuestCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastQuestDateKey, DateTime.now().toIso8601String());
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
