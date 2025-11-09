import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/photo_history_service.dart';
import '../services/quest_service.dart';

// Your profile page showing your stats and achievements
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final PhotoHistoryService _historyService = PhotoHistoryService();
  final QuestService _questService = QuestService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _userStats;
  int _totalSubmissions = 0;
  int _approvedSubmissions = 0;
  int _rejectedSubmissions = 0;
  int _currentStreak = 0;
  int _leaderboardRank = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Get your profile info when page opens
  }

  // Load all your stats and achievements
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      _userStats = await _userService.getUserStats(currentUser.uid);
      _leaderboardRank = await _userService.getUserRank(currentUser.uid);

      final allSubmissions = await _historyService.getHistory();
      _totalSubmissions = allSubmissions.length;
      _approvedSubmissions = allSubmissions.where((s) => s.isApproved).length;
      _rejectedSubmissions = allSubmissions.where((s) => !s.isApproved).length;

      _currentStreak = await _questService.getCurrentStreak();
    } catch (e) {
      print('Error loading profile: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfileData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade700, Colors.green.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Username
                        Text(
                          currentUser?.displayName ?? 'Anonymous',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Rank
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Rank #$_leaderboardRank',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.emoji_events,
                                label: 'Total XP',
                                value: '${_userStats?['totalXP'] ?? 0}',
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.check_circle,
                                label: 'Quests Done',
                                value: '${_userStats?['questsCompleted'] ?? 0}',
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.local_fire_department,
                                label: 'Streak',
                                value: '$_currentStreak days',
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.leaderboard,
                                label: 'Rank',
                                value: '#$_leaderboardRank',
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submission Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Photo Submissions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSubmissionRow(
                              'Total Submissions',
                              _totalSubmissions,
                              Icons.photo_camera,
                              Colors.blue,
                            ),
                            const Divider(height: 24),
                            _buildSubmissionRow(
                              'Approved',
                              _approvedSubmissions,
                              Icons.check_circle,
                              Colors.green,
                            ),
                            const Divider(height: 24),
                            _buildSubmissionRow(
                              'Rejected',
                              _rejectedSubmissions,
                              Icons.cancel,
                              Colors.red,
                            ),
                            if (_totalSubmissions > 0) ...[
                              const Divider(height: 24),
                              _buildApprovalRate(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/history');
                            },
                            icon: const Icon(Icons.history),
                            label: const Text('View Photo History'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/statistics');
                            },
                            icon: const Icon(Icons.bar_chart),
                            label: const Text('View Statistics'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionRow(
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalRate() {
    final rate = (_approvedSubmissions / _totalSubmissions * 100).toStringAsFixed(1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.percent, color: Colors.purple.shade600, size: 24),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Approval Rate',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Text(
              '$rate%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _approvedSubmissions / _totalSubmissions,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
        ),
      ],
    );
  }
}
