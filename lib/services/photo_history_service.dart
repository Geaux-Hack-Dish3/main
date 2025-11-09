import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/photo_history.dart';

class PhotoHistoryService {
  static const String _historyKey = 'photo_history';
  static const int _maxHistoryItems = 100; // Keep last 100 submissions

  // Save a photo submission to history
  Future<void> saveSubmission(PhotoSubmission submission) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Add new submission at the beginning
    history.insert(0, submission);
    
    // Keep only the most recent items
    if (history.length > _maxHistoryItems) {
      history.removeLast();
    }
    
    // Save to SharedPreferences
    final jsonList = history.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  // Get all photo submission history
  Future<List<PhotoSubmission>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    
    return jsonList.map((jsonStr) {
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      return PhotoSubmission.fromJson(jsonMap);
    }).toList();
  }

  // Get approved photos only
  Future<List<PhotoSubmission>> getApprovedPhotos() async {
    final history = await getHistory();
    return history.where((s) => s.isApproved).toList();
  }

  // Get rejected photos only
  Future<List<PhotoSubmission>> getRejectedPhotos() async {
    final history = await getHistory();
    return history.where((s) => !s.isApproved).toList();
  }

  // Get today's submissions
  Future<List<PhotoSubmission>> getTodaysSubmissions() async {
    final history = await getHistory();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return history.where((s) {
      final submittedDate = DateTime(
        s.submittedAt.year,
        s.submittedAt.month,
        s.submittedAt.day,
      );
      return submittedDate.isAtSameMomentAs(today);
    }).toList();
  }

  // Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Check if a quest has an approved submission today
  Future<bool> hasApprovedSubmissionForQuest(String questId) async {
    final todaysSubmissions = await getTodaysSubmissions();
    return todaysSubmissions.any((s) => s.questId == questId && s.isApproved);
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();
    final approved = history.where((s) => s.isApproved).length;
    final rejected = history.where((s) => !s.isApproved).length;
    final total = history.length;
    
    final approvalRate = total > 0 ? (approved / total * 100).toStringAsFixed(1) : '0.0';
    final totalXP = history.fold<int>(0, (sum, s) => sum + s.xpEarned);
    
    // Get today's count
    final todaysSubmissions = await getTodaysSubmissions();
    
    return {
      'totalSubmissions': total,
      'approved': approved,
      'rejected': rejected,
      'approvalRate': approvalRate,
      'totalXP': totalXP,
      'todayCount': todaysSubmissions.length,
    };
  }
}
