class LevelService {
  // Level thresholds - XP required to reach each level
  static const Map<int, int> levelThresholds = {
    1: 0,
    2: 100,
    3: 250,
    4: 500,
    5: 800,
    6: 1200,
    7: 1700,
    8: 2300,
    9: 3000,
    10: 3800,
    11: 4700,
    12: 5700,
    13: 6800,
    14: 8000,
    15: 9300,
    16: 10700,
    17: 12200,
    18: 13800,
    19: 15500,
    20: 17300,
    21: 19200,
    22: 21200,
    23: 23300,
    24: 25500,
    25: 27800,
    26: 30200,
    27: 32700,
    28: 35300,
    29: 38000,
    30: 40800,
  };

  // Level titles
  static const Map<int, String> levelTitles = {
    1: 'Outdoor Newbie',
    2: 'Nature Explorer',
    3: 'Trail Seeker',
    4: 'Park Wanderer',
    5: 'Green Enthusiast',
    6: 'Nature Scout',
    7: 'Outdoor Adventurer',
    8: 'Wildlife Observer',
    9: 'Trail Master',
    10: 'Nature Photographer',
    11: 'Eco Warrior',
    12: 'Forest Keeper',
    13: 'Mountain Climber',
    14: 'Nature Guardian',
    15: 'Wilderness Expert',
    16: 'Outdoor Legend',
    17: 'Nature Sage',
    18: 'Trail Blazer',
    19: 'Eco Champion',
    20: 'Nature Hero',
    21: 'Wilderness Master',
    22: 'Outdoor Guru',
    23: 'Nature Virtuoso',
    24: 'Eco Ambassador',
    25: 'Forest Protector',
    26: 'Nature Sovereign',
    27: 'Wilderness Emperor',
    28: 'Outdoor Deity',
    29: 'Nature Immortal',
    30: 'Legendary Explorer',
  };

  /// Calculate current level from total XP
  static int getLevelFromXP(int totalXP) {
    int level = 1;
    for (int i = 30; i >= 1; i--) {
      if (totalXP >= (levelThresholds[i] ?? 0)) {
        level = i;
        break;
      }
    }
    return level;
  }

  /// Get level title for given level
  static String getLevelTitle(int level) {
    return levelTitles[level] ?? 'Explorer';
  }

  /// Get XP required for next level
  static int getXPForNextLevel(int currentLevel) {
    if (currentLevel >= 30) return levelThresholds[30]!;
    return levelThresholds[currentLevel + 1] ?? 0;
  }

  /// Get XP required for current level
  static int getXPForCurrentLevel(int currentLevel) {
    return levelThresholds[currentLevel] ?? 0;
  }

  /// Calculate progress percentage to next level
  static double getLevelProgress(int totalXP) {
    int currentLevel = getLevelFromXP(totalXP);
    if (currentLevel >= 30) return 1.0; // Max level

    int currentLevelXP = getXPForCurrentLevel(currentLevel);
    int nextLevelXP = getXPForNextLevel(currentLevel);
    int xpInCurrentLevel = totalXP - currentLevelXP;
    int xpNeededForNextLevel = nextLevelXP - currentLevelXP;

    if (xpNeededForNextLevel == 0) return 1.0;
    return xpInCurrentLevel / xpNeededForNextLevel;
  }

  /// Get XP remaining to reach next level
  static int getXPToNextLevel(int totalXP) {
    int currentLevel = getLevelFromXP(totalXP);
    if (currentLevel >= 30) return 0; // Max level
    
    int nextLevelXP = getXPForNextLevel(currentLevel);
    return nextLevelXP - totalXP;
  }

  /// Check if user leveled up (compare old XP to new XP)
  static bool didLevelUp(int oldXP, int newXP) {
    return getLevelFromXP(oldXP) < getLevelFromXP(newXP);
  }

  /// Get reward message for reaching a level
  static String getLevelUpReward(int newLevel) {
    if (newLevel == 5) return 'Unlocked: Community Feed Access!';
    if (newLevel == 10) return 'Bonus: +50 XP for completing today\'s quests!';
    if (newLevel == 15) return 'Achievement: Nature Photographer Badge!';
    if (newLevel == 20) return 'Bonus: Double XP on next quest!';
    if (newLevel == 25) return 'Achievement: Master Explorer Badge!';
    if (newLevel == 30) return 'Legendary Status Achieved!';
    return 'Keep exploring nature!';
  }
}
