const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { upload } = require('../middleware/upload');
const speechService = require('../services/ai/speechService');
const openaiService = require('../services/ai/openaiService');
const { SpeakingSession } = require('../models');

router.post('/session/start', authenticate, async (req, res) => {
  const { topicId, prompt } = req.body;
  const session = await SpeakingSession.create({ userId: req.user.id, topicId, prompt, status: 'in_progress' });
  return success(res, { sessionId: session.id });
});

router.post('/session/submit', authenticate, upload.single('audio'), async (req, res) => {
  const { sessionId } = req.body;
  const session = await SpeakingSession.findOne({ where: { id: sessionId, userId: req.user.id } });
  if (!session) return res.status(404).json({ success: false, message: 'Session not found' });

  const transcript = await speechService.speechToText(req.file.buffer, { languageCode: 'en-US' });
  const aiAnalysis = await openaiService.analyzeSpeaking(transcript.text, session.prompt);

  await session.update({
    transcript: transcript.text,
    pronunciationScore: aiAnalysis.pronunciationScore,
    fluencyScore: aiAnalysis.fluencyScore,
    grammarScore: aiAnalysis.grammarScore,
    vocabularyScore: aiAnalysis.vocabularyScore,
    confidenceScore: aiAnalysis.confidenceScore,
    overallScore: aiAnalysis.overallScore,
    feedback: aiAnalysis.feedback,
    status: 'completed',
  });

  return success(res, { analysis: aiAnalysis, session });
});

module.exports = router;
