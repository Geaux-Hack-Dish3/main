// One player's spot on the leaderboard
class LeaderboardEntry {
  final String userId;
  final String username;
  final int totalXp;
  final int rank;
  final int questsCompleted;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.totalXp,
    required this.rank,
    required this.questsCompleted,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      totalXp: json['totalXp'] as int,
      rank: json['rank'] as int,
      questsCompleted: json['questsCompleted'] as int,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'totalXp': totalXp,
      'rank': rank,
      'questsCompleted': questsCompleted,
      'avatarUrl': avatarUrl,
    };
  }
}
