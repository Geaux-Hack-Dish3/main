// PhotoQuest Backend Server
// IMPORTANT: Move your API key to .env file immediately!

const express = require('express');
const multer = require('multer');
const OpenAI = require('openai');
const cors = require('cors');
const fs = require('fs');
require('dotenv').config();

const app = express();
const upload = multer({ dest: 'uploads/' });

// ⚠️ IMPORTANT: Never commit API keys! Use .env file instead
// Create .env file with: OPENAI_API_KEY=your-key-here
const openai = new OpenAI({ 
  apiKey: process.env.OPENAI_API_KEY
});

app.use(cors());
app.use(express.json());

// Get today's quest
app.get('/api/quests/today', (req, res) => {
  const quest = {
    id: 'quest-' + Date.now(),
    title: 'Capture Nature',
    description: 'Take a photo of something green in nature',
    topic: 'green nature',
    startDate: new Date().toISOString(),
    endDate: new Date(Date.now() + 24*60*60*1000).toISOString(),
    xpReward: 100
  };
  res.json(quest);
});

// Submit photo - AI ONLY determines if outdoor (no rating score)
app.post('/api/submissions', upload.single('photo'), async (req, res) => {
  try {
    const { userId, questId } = req.body;
    const photoPath = req.file.path;
    
    // Get quest topic
    const questTopic = 'outdoor greenery and nature'; // In production, fetch from database
    
    // Read image as base64
    const imageBuffer = fs.readFileSync(photoPath);
    const base64Image = imageBuffer.toString('base64');
    
    console.log('Analyzing photo with OpenAI Vision API...');
    
    // Call OpenAI Vision API - Check for outdoor + greenery
    const response = await openai.chat.completions.create({
      model: "gpt-4o",  // Updated model (replaces deprecated gpt-4-vision-preview)
      messages: [
        {
          role: "user",
          content: [
            { 
              type: "text", 
              text: `You are a photo verification AI for an outdoor nature app. Your job is to determine if a photo is APPROVED or REJECTED.

APPROVAL CRITERIA (ALL must be true):
1. Photo MUST be taken outdoors (not inside buildings)
2. Photo MUST show greenery/nature (trees, grass, plants, flowers, natural landscapes)

REJECT if photo has:
- Indoor elements (walls, ceilings, indoor furniture, artificial lighting)
- No visible greenery or nature (urban concrete, parking lots, pure sky)
- Screenshots, drawings, or non-photos
- Potted plants indoors
- Views through windows (even if outdoor scene is visible)

Return ONLY valid JSON in this exact format:
{
  "isApproved": <true or false>,
  "hasGreenery": <true or false>,
  "isOutdoors": <true or false>,
  "confidence": "<high, medium, or low>",
  "reasoning": "<1-2 sentences explaining why approved or rejected>"
}

Be strict: Both outdoor AND greenery must be present for approval.` 
            },
            {
              type: "image_url",
              image_url: { url: `data:image/jpeg;base64,${base64Image}` }
            }
          ]
        }
      ],
      max_tokens: 300
    });
    
    // Clean the response content (remove markdown code blocks if present)
    let content = response.choices[0].message.content.trim();
    if (content.startsWith('```json')) {
      content = content.replace(/```json\n?/g, '').replace(/```\n?$/g, '');
    } else if (content.startsWith('```')) {
      content = content.replace(/```\n?/g, '');
    }
    
    const aiResponse = JSON.parse(content);
    
    console.log('AI Response:', aiResponse);
    
    // Calculate XP based on approval
    let xpEarned = 0;
    
    if (aiResponse.isApproved) {
      xpEarned = 100; // Photo approved - outdoor with greenery
    } else {
      xpEarned = 0; // No XP for rejected photos
    }
    
    const rating = {
      isApproved: aiResponse.isApproved,
      hasGreenery: aiResponse.hasGreenery,
      isOutdoors: aiResponse.isOutdoors,
      confidence: aiResponse.confidence,
      reasoning: aiResponse.reasoning,
      xpEarned: xpEarned
    };
    
    // Clean up uploaded file
    fs.unlinkSync(photoPath);
    
    res.json({ rating });
  } catch (error) {
    console.error('Error analyzing photo:', error);
    res.status(500).json({ error: 'Failed to analyze photo' });
  }
});

// Get leaderboard
app.get('/api/leaderboard', (req, res) => {
  const leaderboard = [
    { userId: '1', username: 'NatureExplorer', totalXp: 850, rank: 1, questsCompleted: 15 },
    { userId: '2', username: 'PhotoPro', totalXp: 720, rank: 2, questsCompleted: 12 },
    { userId: '3', username: 'OutdoorFan', totalXp: 650, rank: 3, questsCompleted: 10 }
  ];
  res.json(leaderboard);
});

// Get user profile
app.get('/api/users/:userId', (req, res) => {
  const user = {
    id: req.params.userId,
    username: 'TestUser',
    email: 'test@example.com',
    totalXp: 500,
    questsCompleted: 8,
    createdAt: new Date().toISOString()
  };
  res.json(user);
});

// Register new user
app.post('/api/users', (req, res) => {
  const { username, email } = req.body;
  const user = {
    id: 'user-' + Date.now(),
    username,
    email,
    totalXp: 0,
    questsCompleted: 0,
    createdAt: new Date().toISOString()
  };
  res.json(user);
});

// Get recent submissions for voting
app.get('/api/submissions/recent', (req, res) => {
  const submissions = [
    {
      id: 'photo-1',
      userId: 'user-1',
      username: 'NatureExplorer',
      questId: 'quest-1',
      questTitle: 'Green Nature',
      photoUrl: 'https://example.com/photo1.jpg',
      submittedAt: new Date().toISOString(),
      score: 9,
      feedback: 'Great outdoor photo!',
      xpEarned: 100,
      likes: 5,
      dislikes: 1,
      userVote: null
    }
  ];
  res.json(submissions);
});

// Vote on photo
app.post('/api/votes', (req, res) => {
  res.json({ success: true, xpChange: 5 });
});

// Remove vote
app.delete('/api/votes', (req, res) => {
  res.json({ success: true, xpChange: -5 });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`\n🚀 PhotoQuest Backend Server running on port ${PORT}`);
  console.log(`📸 Ready to analyze outdoor photos with AI!\n`);
  console.log(`⚠️  IMPORTANT: Move API key to .env file!`);
  console.log(`   Create .env file with: OPENAI_API_KEY=your-key\n`);
});
