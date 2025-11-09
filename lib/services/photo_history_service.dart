import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/photo_history.dart';
import 'user_service.dart';

class PhotoHistoryService {
  static const String _historyKey = 'photo_history';
  static const int _maxHistoryItems = 100;
  final UserService _userService = UserService();

  // Save a photo you took to your history
  Future<void> saveSubmission(PhotoSubmission submission) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    history.insert(0, submission);
    
    if (history.length > _maxHistoryItems) {
      history.removeLast();
    }
    
    final jsonList = history.map((s) => json.encode(s.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await _userService.savePhotoSubmission(currentUser.uid, submission.toJson());
      } catch (e) {
        print('Error saving to Firestore: $e');
      }
    }
  }

  Future<List<PhotoSubmission>> getHistory() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      try {
        final firestoreHistory = await _userService.getPhotoHistory(currentUser.uid);
        if (firestoreHistory.isNotEmpty) {
          return firestoreHistory.map((json) => PhotoSubmission.fromJson(json)).toList();
        }
      } catch (e) {
        print('Error fetching from Firestore, using local: $e');
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    
    return jsonList.map((jsonStr) {
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      return PhotoSubmission.fromJson(jsonMap);
    }).toList();
  }

  Future<List<PhotoSubmission>> getApprovedPhotos() async {
    final history = await getHistory();
    return history.where((s) => s.isApproved).toList();
  }

  Future<List<PhotoSubmission>> getRejectedPhotos() async {
    final history = await getHistory();
    return history.where((s) => !s.isApproved).toList();
  }

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

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<bool> hasApprovedSubmissionForQuest(String questId) async {
    final todaysSubmissions = await getTodaysSubmissions();
    return todaysSubmissions.any((s) => s.questId == questId && s.isApproved);
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();
    final approved = history.where((s) => s.isApproved).length;
    final rejected = history.where((s) => !s.isApproved).length;
    final total = history.length;
    
    final approvalRate = total > 0 ? (approved / total * 100).toStringAsFixed(1) : '0.0';
    final totalXP = history.fold<int>(0, (sum, s) => sum + s.xpEarned);
    
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
