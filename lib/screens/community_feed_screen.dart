import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feed_post.dart';
import '../services/feed_service.dart';

// Shows everyone's photos where you can vote with likes/dislikes
class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final FeedService _feedService = FeedService();
  List<FeedPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed(); // Get all the photos when page opens
  }

  // Load the 50 most recent photos
  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    
    try {
      final posts = await _feedService.getFeedPosts(limit: 50);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading feed: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVote(FeedPost post, bool isLike) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final voteType = isLike ? 'like' : 'dislike';
      await _feedService.voteOnPost(postId: post.id, voteType: voteType);
      
      await _loadFeed();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLike ? '+20 XP to ${post.username}!' : '-20 XP to ${post.username}'),
            duration: const Duration(seconds: 2),
            backgroundColor: isLike ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error voting')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeed,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No posts yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      Text('Complete quests and share photos!', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) => _buildPostCard(_posts[index]),
                  ),
                ),
    );
  }

  Widget _buildPostCard(FeedPost post) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userVote = currentUser != null ? post.getUserVote(currentUser.uid) : null;
    final totalVotes = post.likes + post.dislikes;
    final likePercentage = totalVotes > 0 ? (post.likes / totalVotes * 100).toInt() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade700,
                  child: Text(post.username[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(post.questTitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: post.score >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: post.score >= 0 ? Colors.green : Colors.red),
                  ),
                  child: Text('${post.score > 0 ? '+' : ''}${post.score}',
                    style: TextStyle(color: post.score >= 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: post.imageUrl != null && post.imageUrl!.isNotEmpty
              ? Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Failed to load image', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Quest Photo', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _handleVote(post, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: userVote == 'like' ? Colors.green.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: userVote == 'like' ? Colors.green : Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(userVote == 'like' ? Icons.thumb_up : Icons.thumb_up_outlined,
                          color: userVote == 'like' ? Colors.green.shade700 : Colors.grey.shade600, size: 20),
                        const SizedBox(width: 6),
                        Text('${post.likes}', style: TextStyle(
                          color: userVote == 'like' ? Colors.green.shade700 : Colors.grey.shade700, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _handleVote(post, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: userVote == 'dislike' ? Colors.red.shade50 : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: userVote == 'dislike' ? Colors.red : Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(userVote == 'dislike' ? Icons.thumb_down : Icons.thumb_down_outlined,
                          color: userVote == 'dislike' ? Colors.red.shade700 : Colors.grey.shade600, size: 20),
                        const SizedBox(width: 6),
                        Text('${post.dislikes}', style: TextStyle(
                          color: userVote == 'dislike' ? Colors.red.shade700 : Colors.grey.shade700, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (totalVotes > 0)
                  Text('$likePercentage% ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

