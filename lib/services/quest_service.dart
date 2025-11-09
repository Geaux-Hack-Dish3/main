import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';

class QuestService {
  static const String _dailyQuestsKey = 'daily_quests';
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _completedQuestsKey = 'completed_quests';

  // All available quest types - outdoor photo challenges
  static final List<Map<String, String>> _allQuestTypes = [
    {
      'id': 'green_nature',
      'title': 'Green Nature',
      'description': 'Capture lush greenery - trees, grass, or plants',
      'icon': '🌳',
      'hint': 'Any outdoor area with grass, trees, or plants works!',
    },
    {
      'id': 'flowers',
      'title': 'Blooming Beauty',
      'description': 'Find and photograph colorful flowers',
      'icon': '🌸',
      'hint': 'Gardens, yards, or potted plants outside count!',
    },
    {
      'id': 'water_scenes',
      'title': 'Water Wonders',
      'description': 'Lakes, rivers, or ocean views',
      'icon': '💧',
      'hint': 'Fountains, ponds, or puddles with greenery work too!',
    },
    {
      'id': 'mountain_views',
      'title': 'Mountain Majesty',
      'description': 'Capture hills, mountains, or scenic overlooks',
      'icon': '⛰️',
      'hint': 'Any elevated outdoor view counts - even small hills!',
    },
    {
      'id': 'wildlife',
      'title': 'Wildlife Encounter',
      'description': 'Birds, animals, or insects in nature',
      'icon': '🦋',
      'hint': 'Birds, squirrels, butterflies - common everywhere!',
    },
    {
      'id': 'sunrise_sunset',
      'title': 'Golden Hour',
      'description': 'Sunrise or sunset with outdoor scenery',
      'icon': '🌅',
      'hint': 'Capture the sky at dawn or dusk from anywhere outside',
    },
    {
      'id': 'forest_trail',
      'title': 'Forest Path',
      'description': 'Woodland trails, forest scenes, or tree canopies',
      'icon': '🌲',
      'hint': 'Groups of trees or tree-lined paths qualify!',
    },
    {
      'id': 'garden',
      'title': 'Garden Glory',
      'description': 'Garden landscapes with plants and flowers',
      'icon': '🏡',
      'hint': 'Your yard, neighbor\'s landscaping, or planters outside',
    },
    {
      'id': 'park_life',
      'title': 'Park Adventure',
      'description': 'Public parks with grass, trees, or playgrounds',
      'icon': '🎡',
      'hint': 'Any outdoor recreational area with greenery works!',
    },
    {
      'id': 'autumn_leaves',
      'title': 'Fall Foliage',
      'description': 'Autumn colors - red, orange, and yellow leaves',
      'icon': '🍂',
      'hint': 'Any colorful leaves on trees or ground count!',
    },
    {
      'id': 'desert_landscape',
      'title': 'Dry Landscape',
      'description': 'Sunny, dry outdoor areas with hardy plants',
      'icon': '🌵',
      'hint': 'Dry grass, small shrubs, or sun-baked areas work!',
    },
    {
      'id': 'beach_scene',
      'title': 'Sandy Scene',
      'description': 'Sandy areas, dirt paths, or open ground',
      'icon': '🏖️',
      'hint': 'Playgrounds with sand, dirt paths, or open terrain!',
    },
    {
      'id': 'wetlands',
      'title': 'Wet Spots',
      'description': 'Areas with water and plants together',
      'icon': '🦆',
      'hint': 'Ponds, ditches, or anywhere water meets vegetation!',
    },
    {
      'id': 'meadow',
      'title': 'Meadow Magic',
      'description': 'Open fields with wildflowers or tall grass',
      'icon': '🌾',
      'hint': 'Any grassy field or lawn with plants works!',
    },
    {
      'id': 'tropical',
      'title': 'Lush Greenery',
      'description': 'Dense, vibrant green plants and foliage',
      'icon': '🌴',
      'hint': 'Thick vegetation, houseplants outside, or leafy areas!',
    },
    {
      'id': 'sky_clouds',
      'title': 'Sky Gazing',
      'description': 'Beautiful cloud formations or blue skies',
      'icon': '☁️',
      'hint': 'Just look up! Include some outdoor scenery below',
    },
    {
      'id': 'outdoor_architecture',
      'title': 'Nature Meets Building',
      'description': 'Buildings surrounded by greenery or outdoor spaces',
      'icon': '🏛️',
      'hint': 'Any building with trees, grass, or plants nearby!',
    },
    {
      'id': 'rocks_stones',
      'title': 'Rocky Terrain',
      'description': 'Interesting rock formations or stone landscapes',
      'icon': '🪨',
      'hint': 'Stone walls, gravel paths, or decorative rocks count!',
    },
    {
      'id': 'backyard',
      'title': 'Backyard Nature',
      'description': 'Your backyard with grass, plants, or trees',
      'icon': '🏠',
      'hint': 'Easy! Just step outside any door - yard or patio!',
    },
    {
      'id': 'pathway',
      'title': 'Outdoor Pathway',
      'description': 'Walking paths, trails, or sidewalks with greenery',
      'icon': '🛤️',
      'hint': 'Sidewalks with grass or trees on the sides work!',
    },
    {
      'id': 'urban_green',
      'title': 'City Green Space',
      'description': 'Urban areas with trees, grass, or green spaces',
      'icon': '🌆',
      'hint': 'Street trees, planters, or any urban greenery!',
    },
    {
      'id': 'reflection',
      'title': 'Nature\'s Mirror',
      'description': 'Reflections in water - trees, sky, or landscapes',
      'icon': '💫',
      'hint': 'Puddles, windows, or any reflective surface outside!',
    },
    {
      'id': 'outdoor_sports',
      'title': 'Sports in Nature',
      'description': 'Outdoor sports fields, courts, or play areas with greenery',
      'icon': '⚽',
      'hint': 'Basketball courts, fields, or playgrounds with grass!',
    },
    {
      'id': 'picnic_spot',
      'title': 'Perfect Picnic',
      'description': 'Outdoor picnic areas with grass and trees',
      'icon': '🧺',
      'hint': 'Any grassy area with trees - parks, yards, or lawns!',
    },
    {
      'id': 'nature_details',
      'title': 'Macro Nature',
      'description': 'Close-up details of leaves, bark, or natural textures',
      'icon': '🔍',
      'hint': 'Get close! Leaf veins, bark patterns, or flower petals!',
    },
  ];

  // Get Eastern Time with proper DST handling
  DateTime _getEasternTime() {
    final now = DateTime.now().toUtc();
    // Eastern Time is UTC-5 (EST) or UTC-4 (EDT)
    // DST runs from 2nd Sunday in March to 1st Sunday in November
    final year = now.year;
    
    // Calculate DST start (2nd Sunday in March at 2 AM)
    final marchFirst = DateTime.utc(year, 3, 1);
    final dstStart = DateTime.utc(year, 3, 8 + (7 - marchFirst.weekday) % 7 + 7, 2);
    
    // Calculate DST end (1st Sunday in November at 2 AM)
    final novemberFirst = DateTime.utc(year, 11, 1);
    final dstEnd = DateTime.utc(year, 11, 1 + (7 - novemberFirst.weekday) % 7, 2);
    
    // Check if we're in DST period
    final isDST = now.isAfter(dstStart) && now.isBefore(dstEnd);
    final offset = isDST ? 4 : 5; // EDT = UTC-4, EST = UTC-5
    
    return now.subtract(Duration(hours: offset));
  }

  // Check if quests need to reset (8:00 PM Eastern Time daily)
  Future<bool> checkAndResetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString(_lastResetDateKey);
    
    // Get current date in Eastern Time, adjusted for 8 PM reset
    final easternTime = _getEasternTime();
    
    // If before 8 PM, use previous day's date for quest consistency
    final adjustedTime = easternTime.hour < 20 
        ? easternTime.subtract(const Duration(days: 1))
        : easternTime;
    
    final today = '${adjustedTime.year}-${adjustedTime.month.toString().padLeft(2, '0')}-${adjustedTime.day.toString().padLeft(2, '0')}';
    
    if (lastResetDate != today) {
      // Time to reset! Generate new quests
      await _generateDailyQuests();
      await prefs.setString(_lastResetDateKey, today);
      await prefs.remove(_completedQuestsKey); // Clear completed quests
      return true;
    }
    
    return false;
  }

  // Generate 3 random unique quests for the day
  Future<void> _generateDailyQuests() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get yesterday's quests to avoid repetition
    final previousQuestIds = prefs.getStringList(_dailyQuestsKey) ?? [];
    
    // Filter out yesterday's quests
    final availableQuests = _allQuestTypes
        .where((q) => !previousQuestIds.contains(q['id']))
        .toList();
    
    // If we filtered out too many, just use all quests
    final questPool = availableQuests.length >= 3 ? availableQuests : _allQuestTypes;
    
    // Use date-based seed so all users get the same quests for the day
    final easternTime = _getEasternTime();
    // Create unique seed: year + dayOfYear to avoid collisions
    final dayOfYear = easternTime.difference(DateTime(easternTime.year, 1, 1)).inDays;
    final seed = easternTime.year * 1000 + dayOfYear;
    
    // Shuffle with seeded random and pick 3
    final shuffled = List<Map<String, String>>.from(questPool)..shuffle(Random(seed));
    final selectedQuests = shuffled.take(3).toList();
    
    // Save quest IDs
    final questIds = selectedQuests.map((q) => q['id']!).toList();
    await prefs.setStringList(_dailyQuestsKey, questIds);
  }

  // Get today's quests
  Future<List<Quest>> getTodaysQuests() async {
    await checkAndResetDaily(); // Always check for reset first
    
    final prefs = await SharedPreferences.getInstance();
    final questIds = prefs.getStringList(_dailyQuestsKey) ?? [];
    
    if (questIds.isEmpty) {
      // First time, generate quests
      await _generateDailyQuests();
      return getTodaysQuests(); // Recursive call to get the new quests
    }
    
    // Get completed quest IDs
    final completedIds = prefs.getStringList(_completedQuestsKey) ?? [];
    
    // Build Quest objects
    final quests = <Quest>[];
    for (int i = 0; i < questIds.length; i++) {
      final questData = _allQuestTypes.firstWhere(
        (q) => q['id'] == questIds[i],
        orElse: () => _allQuestTypes[0],
      );
      
      quests.add(Quest(
        id: questData['id']!,
        title: questData['title']!,
        description: questData['description']!,
        xpReward: 100,
        isCompleted: completedIds.contains(questData['id']),
        icon: questData['icon'],
        hint: questData['hint'],
      ));
    }
    
    return quests;
  }

  // Mark a quest as completed
  Future<void> completeQuest(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = prefs.getStringList(_completedQuestsKey) ?? [];
    
    if (!completedIds.contains(questId)) {
      completedIds.add(questId);
      await prefs.setStringList(_completedQuestsKey, completedIds);
    }
  }

  // Get time until next reset (8:00 PM Eastern Time)
  Duration getTimeUntilReset() {
    final now = DateTime.now().toUtc();
    final easternTime = _getEasternTime();
    
    // Calculate next 8:00 PM Eastern
    var nextReset = DateTime(
      easternTime.year,
      easternTime.month,
      easternTime.day,
      20, 0, 0, // 8:00 PM
    );
    
    // If it's already past 8 PM today, set to tomorrow at 8 PM
    if (easternTime.hour >= 20) {
      nextReset = nextReset.add(const Duration(days: 1));
    }
    
    // Calculate offset back to UTC (DST-aware)
    final isDST = now.isAfter(DateTime.utc(now.year, 3, 8 + (7 - DateTime.utc(now.year, 3, 1).weekday) % 7 + 7, 2)) &&
                  now.isBefore(DateTime.utc(now.year, 11, 1 + (7 - DateTime.utc(now.year, 11, 1).weekday) % 7, 2));
    final offset = isDST ? 4 : 5;
    
    final resetTime = nextReset.add(Duration(hours: offset)); // Convert back to UTC
    return resetTime.difference(now);
  }

  // Get formatted time until reset
  String getTimeUntilResetFormatted() {
    final duration = getTimeUntilReset();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    return '${hours}h ${minutes}m';
  }

  // Calculate current streak (days in a row with at least 1 quest completed)
  Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get last activity date
    final lastActivityStr = prefs.getString('last_activity_date');
    if (lastActivityStr == null) return 0;
    
    final lastActivity = DateTime.parse(lastActivityStr);
    final easternNow = _getEasternTime();
    
    // Adjust for 8 PM reset time
    final adjustedNow = easternNow.hour < 20 
        ? easternNow.subtract(const Duration(days: 1)) 
        : easternNow;
    
    final adjustedLastActivity = lastActivity.hour < 20
        ? lastActivity.subtract(const Duration(days: 1))
        : lastActivity;
    
    final daysSince = adjustedNow.difference(adjustedLastActivity).inDays;
    
    // If more than 1 day gap, streak is broken
    if (daysSince > 1) {
      await prefs.setInt('current_streak', 0);
      return 0;
    }
    
    return prefs.getInt('current_streak') ?? 0;
  }

  // Update streak when a quest is completed
  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();
    final easternNow = now.subtract(const Duration(hours: 5));
    
    final lastActivityStr = prefs.getString('last_activity_date');
    
    if (lastActivityStr == null) {
      // First activity
      await prefs.setInt('current_streak', 1);
      await prefs.setString('last_activity_date', easternNow.toIso8601String());
      return;
    }
    
    final lastActivity = DateTime.parse(lastActivityStr);
    
    // Adjust for 8 PM reset
    final adjustedNow = easternNow.hour < 20
        ? easternNow.subtract(const Duration(days: 1))
        : easternNow;
    
    final adjustedLastActivity = lastActivity.hour < 20
        ? lastActivity.subtract(const Duration(days: 1))
        : lastActivity;
    
    final daysSince = adjustedNow.difference(adjustedLastActivity).inDays;
    
    if (daysSince == 0) {
      // Same day, don't update streak
      return;
    } else if (daysSince == 1) {
      // Consecutive day, increment streak
      final currentStreak = prefs.getInt('current_streak') ?? 0;
      await prefs.setInt('current_streak', currentStreak + 1);
      await prefs.setString('last_activity_date', easternNow.toIso8601String());
    } else {
      // Streak broken, reset to 1
      await prefs.setInt('current_streak', 1);
      await prefs.setString('last_activity_date', easternNow.toIso8601String());
    }
  }
}
