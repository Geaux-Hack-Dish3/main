// A photo someone shared on the community feed
class FeedPost {
  final String id;
  final String userId;
  final String username;
  final String questId;
  final String questTitle;
  final String? imageUrl;
  final DateTime postedAt;
  final int likes;
  final int dislikes;
  final Map<String, String> votes; // Who voted what on this photo

  FeedPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.questId,
    required this.questTitle,
    this.imageUrl,
    required this.postedAt,
    this.likes = 0,
    this.dislikes = 0,
    this.votes = const {},
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      questId: json['questId'] as String,
      questTitle: json['questTitle'] as String,
      imageUrl: json['imageUrl'] as String?,
      postedAt: DateTime.parse(json['postedAt'] as String),
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
      votes: Map<String, String>.from(json['votes'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'questId': questId,
      'questTitle': questTitle,
      'imageUrl': imageUrl,
      'postedAt': postedAt.toIso8601String(),
      'likes': likes,
      'dislikes': dislikes,
      'votes': votes,
    };
  }

  // Calculate net score (likes - dislikes)
  int get score => likes - dislikes;

  // Check if current user has voted
  String? getUserVote(String userId) => votes[userId];
  
  bool hasUserLiked(String userId) => votes[userId] == 'like';
  bool hasUserDisliked(String userId) => votes[userId] == 'dislike';
}
