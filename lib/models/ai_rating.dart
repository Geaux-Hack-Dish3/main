// The score and feedback the AI gives your photo
class AIRating {
  final bool isApproved;
  final bool hasGreenery;
  final bool isOutdoors;
  final String confidence;
  final String reasoning;
  final int xpEarned;

  AIRating({
    required this.isApproved,
    required this.hasGreenery,
    required this.isOutdoors,
    required this.confidence,
    required this.reasoning,
    required this.xpEarned,
  });

  factory AIRating.fromJson(Map<String, dynamic> json) {
    return AIRating(
      isApproved: json['isApproved'] as bool,
      hasGreenery: json['hasGreenery'] as bool,
      isOutdoors: json['isOutdoors'] as bool,
      confidence: json['confidence'] as String,
      reasoning: json['reasoning'] as String,
      xpEarned: json['xpEarned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isApproved': isApproved,
      'hasGreenery': hasGreenery,
      'isOutdoors': isOutdoors,
      'confidence': confidence,
      'reasoning': reasoning,
      'xpEarned': xpEarned,
    };
  }

  String get statusText => isApproved ? 'APPROVED ✅' : 'REJECTED ❌';
  
  String get resultMessage {
    if (isApproved) {
      return 'Great photo! Your outdoor nature shot has been approved.';
    } else if (!isOutdoors) {
      return 'Photo must be taken outdoors. Please try again outside.';
    } else if (!hasGreenery) {
      return 'Photo needs greenery or nature elements. Find some plants or trees!';
    }
    return 'Photo does not meet requirements. Try again!';
  }
}
