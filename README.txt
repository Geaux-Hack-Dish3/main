PhotoQuest

Take outdoor photos. Get points. Beat your friends!

=============================================================================

What is PhotoQuest?

PhotoQuest is a fun app that gives you daily photo challenges. Take a picture outside, and our AI scores it. Earn points, level up, and compete on the leaderboard!

What You Can Do:
- Get 3 new photo quests every day
- Take photos with your camera
- AI judges your photo and gives you points
- Vote on other people's photos (like/dislike)
- Earn XP and level up (30 levels!)
- Compete on the leaderboard
- Keep daily streaks going

=============================================================================

How to Run PhotoQuest

What You Need First:
1. Flutter - Download from flutter.dev
2. Node.js - For the backend server
3. Firebase - Create a free account at firebase.google.com

Step 1: Get the Code
-------------------
git clone https://github.com/Geaux-Hack-Dish3/Photo-Quest/tree/main1.git
cd main1

Step 2: Install Everything
-------------------------
flutter pub get

Step 3: Start the Backend Server
-------------------------------
IMPORTANT: You MUST start the server FIRST before running the app!

Open a NEW terminal window (keep it open) and run:
node server.js

You should see:
"PhotoQuest Backend Server running on port 3000"

Keep this terminal running! Do not close it.

Step 4: Run the App
-----------------

For Web (Chrome):
flutter run -d chrome

For Android Phone:
flutter run

For iPhone:
flutter run -d ios

Step 5: Create an Account
------------------------
When the app opens:
1. Click "Sign Up"
2. Enter a username, email, and password
3. Start taking photos!

=============================================================================

How the App Works

Taking Photos:
1. Open the app and see 3 daily quests
2. Tap "Start Quest" on any quest
3. Take a photo or choose from your gallery
4. Submit it
5. AI grades it (0-10 score)
6. Get 100 XP if approved!

Getting Points:
- Complete a quest: 100 XP
- Someone likes your photo: +20 XP
- Someone dislikes your photo: -20 XP
- Keep your streak going: Bonus XP!

Leveling Up:
- You start at Level 1 (Outdoor Newbie)
- Earn XP to reach Level 30 (Legendary Explorer)
- Each level needs more XP than the last

=============================================================================

Troubleshooting

"Failed to get rating from server" error?
- YOU MUST START THE SERVER FIRST! Open a new terminal and run: node server.js
- Make sure you see "PhotoQuest Backend Server running on port 3000"
- Keep the server terminal open while using the app

App won't start?
- Make sure the backend server is running (node server.js)
- Check that port 3000 is free
- Try closing and restarting both the server and app

Can't take photos?
- Make sure you allowed camera permissions
- Try picking from gallery instead

Not getting points?
- AI only gives points for outdoor photos
- Make sure your photo matches the quest

=============================================================================

Made By

Team Geaux-Hack-Dish3 for the hackathon!

Team Member Names:
- Jakobe Allen
- Edward Summitt
- Kelvin O'Young

=============================================================================

Now go outside and start taking photos!
