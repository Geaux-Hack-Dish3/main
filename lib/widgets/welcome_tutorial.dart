import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shows the welcome tutorial when you first open the app
class WelcomeTutorial extends StatefulWidget {
  const WelcomeTutorial({super.key});

  @override
  State<WelcomeTutorial> createState() => _WelcomeTutorialState();
}

class _WelcomeTutorialState extends State<WelcomeTutorial> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  // The 4 welcome screens explaining how the app works
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': '🌳',
      'title': 'Welcome to PhotoQuest!',
      'description': 'Explore nature, capture outdoor photos, and level up by completing daily quests.',
    },
    {
      'icon': '📸',
      'title': 'Pick a Quest',
      'description': 'Choose from 3 daily quests. Each quest asks you to find and photograph something outdoors.',
    },
    {
      'icon': '🤖',
      'title': 'AI Approval',
      'description': 'Our AI verifies your photo is outdoors with greenery. Get 100 XP for approved photos!',
    },
    {
      'icon': '🏆',
      'title': 'Level Up!',
      'description': 'Earn XP, level up, build streaks, and compete on the leaderboard. Ready to start your journey?',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.green : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        page['icon'],
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        page['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page['description'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 80),
                
                if (_currentPage < _pages.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      // Mark tutorial as completed
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('tutorial_completed', true);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Get Started!'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to check if tutorial should be shown
Future<bool> shouldShowTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool('tutorial_completed') ?? false);
}
