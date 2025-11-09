import 'package:flutter/material.dart';
import '../models/photo_history.dart';
import '../services/photo_history_service.dart';
import 'package:intl/intl.dart';

// Shows all the photos you've taken
class PhotoHistoryScreen extends StatefulWidget {
  const PhotoHistoryScreen({super.key});

  @override
  State<PhotoHistoryScreen> createState() => _PhotoHistoryScreenState();
}

class _PhotoHistoryScreenState extends State<PhotoHistoryScreen> {
  final PhotoHistoryService _historyService = PhotoHistoryService();
  List<PhotoSubmission> _allHistory = [];
  List<PhotoSubmission> _filteredHistory = [];
  String _filter = 'all'; // all, approved, rejected
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory(); // Get all your photos when page opens
  }

  // Load your photo history
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    final history = await _historyService.getHistory();
    setState(() {
      _allHistory = history;
      _applyFilter();
      _isLoading = false;
    });
  }

  // Show only the photos you want to see (all, approved, or rejected)
  void _applyFilter() {
    if (_filter == 'approved') {
      _filteredHistory = _allHistory.where((s) => s.isApproved).toList();
    } else if (_filter == 'rejected') {
      _filteredHistory = _allHistory.where((s) => !s.isApproved).toList();
    } else {
      _filteredHistory = _allHistory;
    }
  }

  void _changeFilter(String filter) {
    setState(() {
      _filter = filter;
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo History'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: Text('All (${_allHistory.length})'),
                  selected: _filter == 'all',
                  onSelected: (_) => _changeFilter('all'),
                  selectedColor: Colors.green.shade200,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Approved (${_allHistory.where((s) => s.isApproved).length})'),
                  selected: _filter == 'approved',
                  onSelected: (_) => _changeFilter('approved'),
                  selectedColor: Colors.green.shade200,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text('Rejected (${_allHistory.where((s) => !s.isApproved).length})'),
                  selected: _filter == 'rejected',
                  onSelected: (_) => _changeFilter('rejected'),
                  selectedColor: Colors.red.shade200,
                ),
              ],
            ),
          ),
          
          // History list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filter == 'all'
                                  ? 'No photos submitted yet'
                                  : 'No ${_filter} photos',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete quests to build your history',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView.builder(
                          itemCount: _filteredHistory.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final submission = _filteredHistory[index];
                            return _buildHistoryCard(submission);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(PhotoSubmission submission) {
    final dateFormat = DateFormat('MMM d, y • h:mm a');
    final isApproved = submission.isApproved;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isApproved ? Colors.green.shade300 : Colors.red.shade300,
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailsDialog(submission),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isApproved
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isApproved ? Icons.check_circle : Icons.cancel,
                  color: isApproved ? Colors.green.shade700 : Colors.red.shade700,
                  size: 36,
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.questTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(submission.submittedAt),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            submission.statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isApproved
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isApproved)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${submission.xpEarned} XP',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(PhotoSubmission submission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              submission.isApproved ? Icons.check_circle : Icons.cancel,
              color: submission.isApproved ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                submission.statusText,
                style: TextStyle(
                  color: submission.isApproved ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                submission.questTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMMM d, y • h:mm a').format(submission.submittedAt),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const Divider(height: 24),
              
              // Criteria breakdown
              _buildCriteriaRow('Outdoors', submission.isOutdoors),
              const SizedBox(height: 8),
              _buildCriteriaRow('Has Greenery', submission.hasGreenery),
              const Divider(height: 24),
              
              // AI Reasoning
              const Text(
                'AI Analysis:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                submission.reasoning,
                style: const TextStyle(fontSize: 14),
              ),
              
              if (submission.isApproved) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Earned ${submission.xpEarned} XP',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow(String label, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          color: passed ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
