// A photo you took that's saved in your history
class PhotoSubmission {
  final String id;
  final String userId;
  final String questId;
  final String questTitle;
  final DateTime submittedAt;
  final bool isApproved;
  final bool hasGreenery;
  final bool isOutdoors;
  final String reasoning;
  final int xpEarned;
  final String? localImagePath; // Where the photo is saved on your phone

  PhotoSubmission({
    required this.id,
    required this.userId,
    required this.questId,
    required this.questTitle,
    required this.submittedAt,
    required this.isApproved,
    required this.hasGreenery,
    required this.isOutdoors,
    required this.reasoning,
    required this.xpEarned,
    this.localImagePath,
  });

  factory PhotoSubmission.fromJson(Map<String, dynamic> json) {
    return PhotoSubmission(
      id: json['id'] as String,
      userId: json['userId'] as String,
      questId: json['questId'] as String,
      questTitle: json['questTitle'] as String? ?? 'Unknown Quest',
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      isApproved: json['isApproved'] as bool,
      hasGreenery: json['hasGreenery'] as bool? ?? false,
      isOutdoors: json['isOutdoors'] as bool? ?? false,
      reasoning: json['reasoning'] as String? ?? '',
      xpEarned: json['xpEarned'] as int,
      localImagePath: json['localImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questId': questId,
      'questTitle': questTitle,
      'submittedAt': submittedAt.toIso8601String(),
      'isApproved': isApproved,
      'hasGreenery': hasGreenery,
      'isOutdoors': isOutdoors,
      'reasoning': reasoning,
      'xpEarned': xpEarned,
      'localImagePath': localImagePath,
    };
  }

  String get statusText => isApproved ? 'APPROVED' : 'REJECTED';
  String get statusEmoji => isApproved ? '✅' : '❌';
}
