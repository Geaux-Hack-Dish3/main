import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feed_post.dart';
import 'user_service.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  static const int XP_PER_LIKE = 20;
  static const int XP_PER_DISLIKE = -20;

  Future<String> createPost({
    required String questId,
    required String questTitle,
    String? imageUrl,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final postId = DateTime.now().millisecondsSinceEpoch.toString();
    final post = FeedPost(
      id: postId,
      userId: currentUser.uid,
      username: currentUser.displayName ?? 'Anonymous',
      questId: questId,
      questTitle: questTitle,
      imageUrl: imageUrl,
      postedAt: DateTime.now(),
    );

    await _firestore.collection('feed_posts').doc(postId).set(post.toJson());
    return postId;
  }

  Future<List<FeedPost>> getFeedPosts({int limit = 50}) async {
    final querySnapshot = await _firestore
        .collection('feed_posts')
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) {
      return FeedPost.fromJson(doc.data());
    }).toList();
  }

  Future<void> voteOnPost({
    required String postId,
    required String voteType, // 'like' or 'dislike'
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final postRef = _firestore.collection('feed_posts').doc(postId);
    final postDoc = await postRef.get();
    
    if (!postDoc.exists) throw Exception('Post not found');

    final post = FeedPost.fromJson(postDoc.data()!);
    final previousVote = post.getUserVote(currentUser.uid);
    
    int xpChange = 0;
    
    if (previousVote == voteType) {
      if (voteType == 'like') {
        xpChange = -XP_PER_LIKE;
      } else {
        xpChange = XP_PER_DISLIKE;
      }
    } else if (previousVote != null) {
      if (voteType == 'like') {
        xpChange = XP_PER_LIKE - XP_PER_DISLIKE;
      } else {
        xpChange = XP_PER_DISLIKE - XP_PER_LIKE;
      }
    } else {
      xpChange = voteType == 'like' ? XP_PER_LIKE : XP_PER_DISLIKE;
    }

    await _firestore.runTransaction((transaction) async {
      final freshPost = await transaction.get(postRef);
      if (!freshPost.exists) throw Exception('Post not found');

      final currentVotes = Map<String, String>.from(freshPost.data()!['votes'] ?? {});
      int currentLikes = freshPost.data()!['likes'] ?? 0;
      int currentDislikes = freshPost.data()!['dislikes'] ?? 0;

      if (previousVote == 'like') currentLikes--;
      if (previousVote == 'dislike') currentDislikes--;

      if (previousVote == voteType) {
        currentVotes.remove(currentUser.uid);
      } else {
        currentVotes[currentUser.uid] = voteType;
        if (voteType == 'like') currentLikes++;
        if (voteType == 'dislike') currentDislikes++;
      }

      transaction.update(postRef, {
        'votes': currentVotes,
        'likes': currentLikes,
        'dislikes': currentDislikes,
      });
    });

    if (xpChange != 0) {
      try {
        await _userService.incrementUserXP(post.userId, xpChange);
      } catch (e) {
        print('Error updating user XP: $e');
      }
    }
  }

  Future<List<FeedPost>> getUserPosts(String userId) async {
    final querySnapshot = await _firestore
        .collection('feed_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('postedAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return FeedPost.fromJson(doc.data());
    }).toList();
  }

  Future<void> deletePost(String postId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final postDoc = await _firestore.collection('feed_posts').doc(postId).get();
    if (!postDoc.exists) throw Exception('Post not found');

    final post = FeedPost.fromJson(postDoc.data()!);
    if (post.userId != currentUser.uid) {
      throw Exception('You can only delete your own posts');
    }

    await _firestore.collection('feed_posts').doc(postId).delete();
  }

  Stream<List<FeedPost>> streamFeedPosts({int limit = 50}) {
    return _firestore
        .collection('feed_posts')
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FeedPost.fromJson(doc.data());
      }).toList();
    });
  }
}
