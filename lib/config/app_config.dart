class AppConfig {
  // Where the server lives (like a website address)
  static const String apiBaseUrl = 'http://localhost:3000/api';
  
  // Different places we can ask the server for stuff
  static const String questsEndpoint = '/quests';
  static const String submitPhotoEndpoint = '/submissions';
  static const String leaderboardEndpoint = '/leaderboard';
  static const String userEndpoint = '/users';
  
  // How big photos can be and how many quests per day
  static const int maxPhotoSizeMB = 5;
  static const int dailyQuestLimit = 3;
  
  // UI Constants
  static const double borderRadius = 16.0;
  static const double padding = 16.0;
}
