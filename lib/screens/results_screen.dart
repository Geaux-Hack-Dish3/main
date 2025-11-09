import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ai_rating.dart';
import '../models/quest.dart';
import '../models/photo_history.dart';
import '../services/photo_history_service.dart';
import '../services/quest_service.dart';
import '../services/user_service.dart';
import '../services/feed_service.dart';
import '../services/level_service.dart';
import '../widgets/xp_gain_animation.dart';

class ResultsScreen extends StatefulWidget {
  final AIRating rating;
  final Quest quest;
  final File? photoFile;
  final Uint8List? webImageBytes;

  const ResultsScreen({
    super.key,
    required this.rating,
    required this.quest,
    this.photoFile,
    this.webImageBytes,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final PhotoHistoryService _historyService = PhotoHistoryService();
  final QuestService _questService = QuestService();
  final UserService _userService = UserService();
  final FeedService _feedService = FeedService();
  
  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid ?? 'local_user';
    final username = currentUser?.displayName ?? 'Anonymous';
    
    final submission = PhotoSubmission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      questId: widget.quest.id,
      questTitle: widget.quest.title,
      submittedAt: DateTime.now(),
      isApproved: widget.rating.isApproved,
      hasGreenery: widget.rating.hasGreenery,
      isOutdoors: widget.rating.isOutdoors,
      reasoning: widget.rating.reasoning,
      xpEarned: widget.rating.xpEarned,
      localImagePath: widget.photoFile?.path,
    );
    
    await _historyService.saveSubmission(submission);
    
    if (widget.rating.isApproved) {
      await _questService.completeQuest(widget.quest.id);
      
      await _questService.updateStreak();
      
      try {
        await _userService.createOrUpdateUser(userId, username);
        
        final oldXP = (await _userService.getUserStats(userId))?['totalXP'] ?? 0;
        
        await _userService.incrementUserXP(userId, widget.rating.xpEarned);
        
        _checkLevelUp(oldXP, oldXP + widget.rating.xpEarned);
        
        String? photoUrl;
        try {
          print('🔄 Converting photo to Base64...');
          if (widget.webImageBytes != null) {
            final base64Image = 'data:image/jpeg;base64,${base64Encode(widget.webImageBytes!)}';
            photoUrl = base64Image;
            print('✅ Photo converted to Base64 (${widget.webImageBytes!.length} bytes)');
          } else if (widget.photoFile != null) {
            final bytes = await widget.photoFile!.readAsBytes();
            final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
            photoUrl = base64Image;
            print('✅ Photo converted to Base64 (${bytes.length} bytes)');
          }
        } catch (e) {
          print('❌ Error converting photo: $e');
          photoUrl = null;
        }
        
        try {
          print('📝 Creating feed post...');
          print('   Photo URL: ${photoUrl ?? "null (no photo uploaded)"}');
          await _feedService.createPost(
            questId: widget.quest.id,
            questTitle: widget.quest.title,
            imageUrl: photoUrl,
          );
          print('✅ Feed post created successfully!');
        } catch (e, stackTrace) {
          print('❌ Error creating feed post: $e');
          print('   Stack trace: $stackTrace');
        }
      } catch (e) {
        print('Error updating Firestore: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Results'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: kIsWeb && widget.webImageBytes != null
                      ? Image.memory(widget.webImageBytes!, fit: BoxFit.cover)
                      : widget.photoFile != null
                          ? Image.file(widget.photoFile!, fit: BoxFit.cover)
                          : const Center(child: Text('No image')),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: widget.rating.isApproved
                              ? [Colors.green.shade600, Colors.green.shade800]
                              : [Colors.red.shade600, Colors.red.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            widget.rating.isApproved ? Icons.check_circle : Icons.cancel,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.rating.statusText,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.rating.resultMessage,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // XP Earned
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.rating.xpEarned} XP Earned',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Community Voting Info
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.blue.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Community Voting',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your photo will appear in the community feed where others can vote!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.thumb_up, size: 16, color: Colors.green.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Likes = +20 XP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.thumb_down, size: 16, color: Colors.red.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dislikes = -20 XP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home, size: 24),
                    label: const Text(
                      'Return Home',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // XP Gain Animation Overlay (only if approved)
      if (widget.rating.isApproved)
        Positioned(
          top: 350,
          left: 0,
          right: 0,
          child: Center(
            child: XPGainAnimation(
              xpGained: widget.rating.xpEarned,
            ),
          ),
        ),
      ],
    ),
    );
  }

  void _checkLevelUp(int oldXP, int newXP) {
    final oldLevel = LevelService.getLevelFromXP(oldXP);
    final newLevel = LevelService.getLevelFromXP(newXP);
    
    if (newLevel > oldLevel) {
      // Level up! Show celebration dialog
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          _showLevelUpDialog(newLevel);
        }
      });
    }
  }

  void _showLevelUpDialog(int newLevel) {
    final levelTitle = LevelService.getLevelTitle(newLevel);
    final reward = LevelService.getLevelUpReward(newLevel);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  size: 60,
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                '🎉 LEVEL UP! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // New Level
              Text(
                'Level $newLevel',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Level Title
              Text(
                levelTitle,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              
              // Reward
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reward,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
