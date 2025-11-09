// A quest is like a mission to take a specific type of photo
class Quest {
  final String id;
  final String title;
  final String description;
  final String? topic;
  final DateTime? startDate;
  final DateTime? endDate;
  final int xpReward;
  final bool isCompleted;
  final String? icon;
  final String? hint;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    this.topic,
    this.startDate,
    this.endDate,
    required this.xpReward,
    this.isCompleted = false,
    this.icon,
    this.hint,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      topic: json['topic'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      xpReward: json['xpReward'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'topic': topic,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'icon': icon,
    };
  }

  bool get isActive {
    if (startDate == null || endDate == null) return true; // Daily quests are always active
    final now = DateTime.now();
    return now.isAfter(startDate!) && now.isBefore(endDate!);
  }
}
