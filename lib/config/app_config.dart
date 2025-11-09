class AppConfig {
  // Backend API URL
  static const String apiBaseUrl = 'http://localhost:3000/api';
  
  // API Endpoints
  static const String questsEndpoint = '/quests';
  static const String submitPhotoEndpoint = '/submissions';
  static const String leaderboardEndpoint = '/leaderboard';
  static const String userEndpoint = '/users';
  
  // App Settings
  static const int maxPhotoSizeMB = 5;
  static const int dailyQuestLimit = 3;
  
  // UI Constants
  static const double borderRadius = 16.0;
  static const double padding = 16.0;
}
