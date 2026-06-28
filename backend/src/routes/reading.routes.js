const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { upload } = require('../middleware/upload');
const speechService = require('../services/ai/speechService');
const { ReadingSession } = require('../models');

const passages = [
  { id: 1, title: 'The Amazon Rainforest', text: 'The Amazon rainforest, often called the lungs of the Earth, produces about 20% of the world\'s oxygen. It spans across nine countries in South America...', level: 'B1', wordCount: 95 },
  { id: 2, title: 'The History of Coffee', text: 'Coffee is one of the world\'s most popular beverages. It was first discovered in Ethiopia around the 9th century when a goat herder noticed his goats became unusually energetic after eating berries from a certain tree...', level: 'A2', wordCount: 78 },
  { id: 3, title: 'Artificial Intelligence', text: 'Artificial intelligence, or AI, refers to the simulation of human intelligence in machines. These machines are programmed to think and learn like humans, solving problems that would normally require human intelligence...', level: 'B2', wordCount: 102 },
];

router.get('/passages', authenticate, (req, res) => success(res, { passages }));

router.post('/session/start', authenticate, async (req, res) => {
  const { passageId } = req.body;
  const passage = passages.find((p) => p.id === passageId);
  if (!passage) return res.status(404).json({ success: false, message: 'Passage not found' });
  const session = await ReadingSession.create({ userId: req.user.id, passageId, passageText: passage.text, status: 'in_progress' });
  return success(res, { session, passage });
});

router.post('/session/submit', authenticate, upload.single('audio'), async (req, res) => {
  const { sessionId } = req.body;
  const session = await ReadingSession.findOne({ where: { id: sessionId, userId: req.user.id } });
  if (!session) return res.status(404).json({ success: false, message: 'Session not found' });

  const transcript = await speechService.speechToText(req.file.buffer, { languageCode: 'en-US', enableWordTimeOffsets: true });
  const analysis = await speechService.analyzePronunciation(transcript, session.passageText);

  await session.update({
    transcript: transcript.text,
    pronunciationScore: analysis.pronunciationScore,
    accuracyScore: analysis.accuracyScore,
    fluencyScore: analysis.fluencyScore,
    wordsPerMinute: analysis.wordsPerMinute,
    mispronounced: analysis.mispronounced,
    status: 'completed',
  });

  return success(res, { analysis, session });
});

module.exports = router;
