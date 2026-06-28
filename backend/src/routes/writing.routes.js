const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const openaiService = require('../services/ai/openaiService');
const { WritingSubmission } = require('../models');

const topics = [
  { id: 1, title: 'My Family', level: 'A1', category: 'Personal' },
  { id: 2, title: 'My Holiday', level: 'A2', category: 'Personal' },
  { id: 3, title: 'Technology in Daily Life', level: 'B1', category: 'Technology' },
  { id: 4, title: 'Climate Change Solutions', level: 'B2', category: 'Environment' },
  { id: 5, title: 'The Future of Education', level: 'C1', category: 'Education' },
  { id: 6, title: 'Globalisation and Culture', level: 'C2', category: 'Society' },
  { id: 7, title: 'Advantages of Remote Work', level: 'B1', category: 'Work' },
  { id: 8, title: 'Travel Broadens the Mind', level: 'B2', category: 'Travel' },
  { id: 9, title: 'The Role of Sports in Society', level: 'B1', category: 'Sports' },
  { id: 10, title: 'Healthcare Challenges', level: 'B2', category: 'Health' },
];

router.get('/topics', authenticate, (req, res) => success(res, { topics }));

router.post('/submit', authenticate, async (req, res) => {
  const { topicId, text } = req.body;
  const topic = topics.find((t) => t.id === topicId);
  const analysis = await openaiService.analyzeWriting(text, topic?.title || 'General');

  const submission = await WritingSubmission.create({
    userId: req.user.id,
    topicId,
    originalText: text,
    correctedText: analysis.correctedText,
    score: analysis.score,
    grammarScore: analysis.grammarScore,
    vocabularyScore: analysis.vocabularyScore,
    structureScore: analysis.structureScore,
    feedback: analysis.feedback,
  });

  return success(res, { submission, analysis }, 'Writing analysed');
});

router.get('/history', authenticate, async (req, res) => {
  const submissions = await WritingSubmission.findAll({ where: { userId: req.user.id }, order: [['createdAt', 'DESC']], limit: 20 });
  return success(res, { submissions });
});

module.exports = router;
