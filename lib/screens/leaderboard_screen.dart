import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/leaderboard_entry.dart';
import '../services/user_service.dart';

// Shows the top players ranked by XP points
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final UserService _userService = UserService();
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard(); // Get the rankings when page opens
  }

  // Get the top 100 players
  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    try {
      final leaderboardData = await _userService.getLeaderboard(limit: 100);
      
      _entries = leaderboardData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return LeaderboardEntry(
          userId: data['userId'] as String,
          rank: index + 1,
          username: data['username'] as String,
          totalXp: data['totalXP'] as int,
          questsCompleted: data['questsCompleted'] as int,
        );
      }).toList();
    } catch (e) {
      print('Error loading leaderboard: $e');
      _entries = [];
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: _entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.leaderboard,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No rankings yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete quests to appear here!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return _buildLeaderboardItem(entry, index);
                      },
                    ),
            ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final isTopThree = entry.rank <= 3;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser != null && entry.userId == currentUser.uid;
    
    return Card(
      elevation: isTopThree ? 8 : (isCurrentUser ? 4 : 2),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrentUser 
            ? BorderSide(color: Colors.green.shade700, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isTopThree
              ? LinearGradient(
                  colors: _getRankGradient(entry.rank),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isTopThree ? Colors.white : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getRankDisplay(entry.rank),
                    style: TextStyle(
                      fontSize: isTopThree ? 20 : 18,
                      fontWeight: FontWeight.bold,
                      color: isTopThree
                          ? _getRankColor(entry.rank)
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              CircleAvatar(
                radius: 28,
                backgroundColor: isTopThree ? Colors.white : Colors.green.shade700,
                child: Text(
                  entry.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isTopThree ? Colors.green.shade700 : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.username,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isTopThree ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 16,
                          color: isTopThree ? Colors.white70 : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.questsCompleted} quests',
                          style: TextStyle(
                            fontSize: 14,
                            color: isTopThree ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // XP Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isTopThree ? Colors.white : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: isTopThree ? Colors.amber.shade700 : Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.totalXp}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isTopThree ? Colors.green.shade900 : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRankDisplay(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.grey.shade600;
      case 3:
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  List<Color> _getRankGradient(int rank) {
    switch (rank) {
      case 1:
        return [Colors.amber.shade600, Colors.amber.shade400];
      case 2:
        return [Colors.grey.shade500, Colors.grey.shade300];
      case 3:
        return [Colors.orange.shade600, Colors.orange.shade400];
      default:
        return [Colors.white, Colors.white];
    }
  }
}
