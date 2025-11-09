import 'package:flutter/material.dart';
import '../services/photo_history_service.dart';
import '../services/quest_service.dart';

// Shows cool charts and numbers about your progress
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final PhotoHistoryService _historyService = PhotoHistoryService();
  final QuestService _questService = QuestService();
  
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics(); // Get all the stats when page opens
  }

  // Calculate all your stats and numbers
  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    final stats = await _historyService.getStatistics();
    final quests = await _questService.getTodaysQuests();
    final completedToday = quests.where((q) => q.isCompleted).length;
    final timeUntilReset = _questService.getTimeUntilReset();
    
    setState(() {
      _stats = {
        ...stats,
        'completedToday': completedToday,
        'totalQuests': quests.length,
        'hoursUntilReset': timeUntilReset.inHours,
        'minutesUntilReset': timeUntilReset.inMinutes % 60,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Your Performance',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track your outdoor photography progress',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Today's Progress
                    _buildSectionHeader('Today\'s Progress', Icons.today),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Quests Completed',
                            value: '${_stats['completedToday']}/${_stats['totalQuests']}',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Photos Today',
                            value: '${_stats['todayCount']}',
                            icon: Icons.photo_camera,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTimeUntilResetCard(),
                    const SizedBox(height: 24),

                    // Overall Stats
                    _buildSectionHeader('Overall Stats', Icons.analytics),
                    const SizedBox(height: 12),
                    _buildLargeStatCard(
                      title: 'Total XP Earned',
                      value: '${_stats['totalXP']}',
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Photos Submitted',
                            value: '${_stats['totalSubmissions']}',
                            icon: Icons.photo_library,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Approval Rate',
                            value: '${_stats['approvalRate']}%',
                            icon: Icons.verified,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Breakdown
                    _buildSectionHeader('Breakdown', Icons.pie_chart),
                    const SizedBox(height: 12),
                    _buildBreakdownCard(),
                    const SizedBox(height: 24),

                    // Tips
                    _buildTipsCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 40),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUntilResetCard() {
    final hours = _stats['hoursUntilReset'] ?? 0;
    final minutes = _stats['minutesUntilReset'] ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange.shade700, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New Quests In',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hours}h ${minutes}m',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
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

  Widget _buildBreakdownCard() {
    final approved = _stats['approved'] ?? 0;
    final rejected = _stats['rejected'] ?? 0;
    final total = _stats['totalSubmissions'] ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBreakdownRow(
              label: 'Approved Photos',
              count: approved,
              total: total,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow(
              label: 'Rejected Photos',
              count: rejected,
              total: total,
              color: Colors.red,
            ),
            if (total > 0) ...[
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Success Rate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_stats['approvalRate']}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '$count ($percentage%)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    final approvalRate = double.tryParse(_stats['approvalRate']?.toString() ?? '0') ?? 0;
    
    String tip;
    IconData tipIcon;
    Color tipColor;
    
    if (approvalRate >= 80) {
      tip = 'Excellent work! Your photos consistently meet the outdoor + greenery criteria.';
      tipIcon = Icons.emoji_events;
      tipColor = Colors.amber;
    } else if (approvalRate >= 60) {
      tip = 'Good job! Try to ensure your photos clearly show outdoor greenery for better approval rates.';
      tipIcon = Icons.thumb_up;
      tipColor = Colors.green;
    } else if (_stats['totalSubmissions'] > 0) {
      tip = 'Tip: Make sure your photos are taken outdoors and show visible plants, trees, or grass.';
      tipIcon = Icons.lightbulb;
      tipColor = Colors.orange;
    } else {
      tip = 'Start completing quests to track your statistics!';
      tipIcon = Icons.info;
      tipColor = Colors.blue;
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: tipColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(tipIcon, color: tipColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                tip,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
