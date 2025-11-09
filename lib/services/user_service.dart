import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> createOrUpdateUser(String userId, String username) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      await userDoc.set({
        'userId': userId,
        'username': username,
        'totalXP': 0,
        'questsCompleted': 0,
        'currentStreak': 0,
        'lastStreakDate': null,
        'dailyQuests': [],
        'completedQuestsToday': [],
        'lastQuestResetDate': null,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
    } else {
      await userDoc.update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }
  
  Future<void> incrementUserXP(String userId, int xpAmount) async {
    final userDoc = _firestore.collection('users').doc(userId);
    
    await userDoc.update({
      'totalXP': FieldValue.increment(xpAmount),
      'questsCompleted': FieldValue.increment(1),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }
  
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 100}) async {
    final querySnapshot = await _firestore
        .collection('users')
        .orderBy('totalXP', descending: true)
        .limit(limit)
        .get();
    
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'userId': data['userId'] ?? '',
        'username': data['username'] ?? 'Anonymous',
        'totalXP': data['totalXP'] ?? 0,
        'questsCompleted': data['questsCompleted'] ?? 0,
        'rank': 0,
      };
    }).toList();
  }
  
  Future<int> getUserRank(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return 0;
    
    final userData = userDoc.data()!;
    final userXP = userData['totalXP'] ?? 0;
    
    final querySnapshot = await _firestore
        .collection('users')
        .where('totalXP', isGreaterThan: userXP)
        .get();
    
    return querySnapshot.docs.length + 1;
  }
  
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return null;
    
    return userDoc.data();
  }
  
  Future<void> updateDailyQuests(String userId, List<String> questIds) async {
    await _firestore.collection('users').doc(userId).update({
      'dailyQuests': questIds,
      'lastQuestResetDate': FieldValue.serverTimestamp(),
    });
  }
  
  Future<void> updateCompletedQuests(String userId, List<String> completedQuestIds) async {
    await _firestore.collection('users').doc(userId).update({
      'completedQuestsToday': completedQuestIds,
    });
  }
  
  Future<void> updateStreak(String userId, int streakDays) async {
    await _firestore.collection('users').doc(userId).update({
      'currentStreak': streakDays,
      'lastStreakDate': FieldValue.serverTimestamp(),
    });
  }
  
  Future<void> savePhotoSubmission(String userId, Map<String, dynamic> submission) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('photo_history')
        .doc(submission['id'])
        .set(submission);
  }
  
  Future<List<Map<String, dynamic>>> getPhotoHistory(String userId) async {
    final querySnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('photo_history')
        .orderBy('submittedAt', descending: true)
        .limit(100)
        .get();
    
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
