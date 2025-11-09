import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/quest.dart';
import '../services/quest_service.dart';
import '../services/photo_history_service.dart';
import '../services/user_service.dart';
import '../services/level_service.dart';
import 'camera_screen.dart';
import 'leaderboard_screen.dart';
import 'community_feed_screen.dart';
import 'photo_history_screen.dart';
import 'statistics_screen.dart';
import '../widgets/welcome_tutorial.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuestService _questService = QuestService();
  final PhotoHistoryService _historyService = PhotoHistoryService();
  final UserService _userService = UserService();
  
  List<Quest> _todayQuests = [];
  int _totalXP = 0;
  int _questsCompleted = 0;
  int _currentStreak = 0;
  int _completedTodayCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    // Show tutorial on first launch
    final showTutorial = await shouldShowTutorial();
    if (showTutorial && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const WelcomeTutorial(),
          );
        }
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Check and reset daily quests if needed
    await _questService.checkAndResetDaily();
    
    // Load Firebase user data
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        // Get user stats from Firestore
        final userDoc = await _userService.getUserStats(firebaseUser.uid);
        _totalXP = userDoc?['totalXP'] ?? 0;
        _questsCompleted = userDoc?['questsCompleted'] ?? 0;
      } catch (e) {
        print('Error loading user stats: $e');
      }
    }
    
    // Calculate streak
    _currentStreak = await _questService.getCurrentStreak();
    
    // Load today's 3 quests
    _todayQuests = await _questService.getTodaysQuests();
    
    // Count how many quests completed today
    _completedTodayCount = _todayQuests.where((q) => q.isCompleted).length;
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhotoQuest'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Profile Button - Quick access to user profile
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.account_circle, size: 28),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade700, width: 1),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '${LevelService.getLevelFromXP(_totalXP)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Photo History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhotoHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await firebase_auth.FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Stats Card
                      _buildUserStatsCard(),
                      const SizedBox(height: 20),
                      
                      // Community Feed Button
                      _buildCommunityFeedButton(),
                      const SizedBox(height: 20),
                      
                      // Today's Quests Header
                      _buildQuestsHeader(),
                      const SizedBox(height: 16),
                      
                      // Display 3 quests
                      ..._todayQuests.map((quest) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildQuestCard(quest),
                      )),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUserStatsCard() {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final displayName = firebaseUser?.displayName ?? 'Guest';
    
    // Calculate level and progress
    final currentLevel = LevelService.getLevelFromXP(_totalXP);
    final levelTitle = LevelService.getLevelTitle(currentLevel);
    final levelProgress = LevelService.getLevelProgress(_totalXP);
    final xpToNext = LevelService.getXPToNextLevel(_totalXP);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar and Name
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.green.shade700,
                  child: Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        levelTitle,
                        style: TextStyle(fontSize: 14, color: Colors.green.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Level Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Level $currentLevel',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      currentLevel >= 30 ? 'MAX LEVEL!' : '$xpToNext XP to next level',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: levelProgress,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total XP', '$_totalXP', Icons.bolt),
                _buildStatItem('Completed', '$_questsCompleted', Icons.task_alt),
                _buildStreakItem(),
              ],
            ),
            
            // Today's Progress
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.today, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '$_completedTodayCount/3 quests completed',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(3, (index) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                index < _completedTodayCount ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 16,
                                color: index < _completedTodayCount ? Colors.green : Colors.grey,
                              ),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreakItem() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 4),
            Text(
              '$_currentStreak',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Day Streak',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCommunityFeedButton() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityFeedScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Feed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Vote on photos and earn bonus XP!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestsHeader() {
    final timeUntilReset = _questService.getTimeUntilReset();
    final hours = timeUntilReset.inHours;
    final minutes = timeUntilReset.inMinutes % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Today\'s Quests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.timer, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Text(
                '${hours}h ${minutes}m',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestCard(Quest quest) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: quest.isCompleted
            ? () {
                // Show message that quest is already completed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Quest already completed! Come back tomorrow for new quests.'),
                    backgroundColor: Colors.orange.shade700,
                  ),
                );
              }
            : () async {
                // Check if quest already has an approved submission
                final hasSubmission = await _historyService.hasApprovedSubmissionForQuest(quest.id);
                
                if (hasSubmission) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('You already completed this quest today!'),
                      backgroundColor: Colors.orange.shade700,
                    ),
                  );
                  // Mark as completed and reload
                  await _questService.completeQuest(quest.id);
                  _loadData();
                  return;
                }
                
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(quest: quest),
                  ),
                );

                if (result == true) {
                  // Reload data to check completion status
                  _loadData();
                }
              },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: quest.isCompleted
                ? LinearGradient(
                    colors: [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Quest icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    quest.icon ?? '📸',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Quest details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if (quest.hint != null && !quest.isCompleted) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.amber.shade200, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              quest.hint!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${quest.xpReward} XP',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status indicator
              Icon(
                quest.isCompleted ? Icons.check_circle : Icons.camera_alt,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
