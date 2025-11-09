import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create or update user document
  Future<void> createOrUpdateUser(String userId, String username) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      // Create new user document
      await userDoc.set({
        'userId': userId,
        'username': username,
        'totalXP': 0,
        'questsCompleted': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
    } else {
      // Update last active time
      await userDoc.update({
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }
  
  // Increment user XP when photo is approved
  Future<void> incrementUserXP(String userId, int xpAmount) async {
    final userDoc = _firestore.collection('users').doc(userId);
    
    await userDoc.update({
      'totalXP': FieldValue.increment(xpAmount),
      'questsCompleted': FieldValue.increment(1),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }
  
  // Get leaderboard (top users by XP)
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
        'rank': 0, // Will be set after fetching
      };
    }).toList();
  }
  
  // Get current user's rank
  Future<int> getUserRank(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return 0;
    
    final userData = userDoc.data()!;
    final userXP = userData['totalXP'] ?? 0;
    
    // Count users with more XP
    final querySnapshot = await _firestore
        .collection('users')
        .where('totalXP', isGreaterThan: userXP)
        .get();
    
    return querySnapshot.docs.length + 1;
  }
  
  // Get user stats
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return null;
    
    return userDoc.data();
  }
}
