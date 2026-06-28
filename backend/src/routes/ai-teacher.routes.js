const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const openaiService = require('../services/ai/openaiService');
const { ChatMessage } = require('../models');

router.get('/history', authenticate, async (req, res) => {
  const messages = await ChatMessage.findAll({
    where: { userId: req.user.id, sessionType: 'ai_teacher' },
    order: [['createdAt', 'ASC']],
    limit: 100,
  });
  return success(res, { messages });
});

router.post('/message', authenticate, async (req, res) => {
  const { message, sessionId } = req.body;

  await ChatMessage.create({ userId: req.user.id, sessionType: 'ai_teacher', role: 'user', content: message, sessionId });

  const history = await ChatMessage.findAll({
    where: { userId: req.user.id, sessionType: 'ai_teacher', sessionId },
    order: [['createdAt', 'ASC']],
    limit: 20,
  });

  const historyForAI = history.map((m) => ({ role: m.role, content: m.content }));
  const userProfile = { level: req.user.cefrLevel || 'B1', variant: req.user.englishVariant || 'US' };

  const aiResponse = await openaiService.generateTeacherResponse(message, historyForAI, userProfile);

  const aiMessage = await ChatMessage.create({
    userId: req.user.id,
    sessionType: 'ai_teacher',
    role: 'assistant',
    content: aiResponse,
    sessionId,
  });

  return success(res, { message: aiMessage });
});

router.post('/correct-grammar', authenticate, async (req, res) => {
  const { text } = req.body;
  const result = await openaiService.analyzeGrammar(text);
  return success(res, { result });
});

router.post('/explain', authenticate, async (req, res) => {
  const { concept } = req.body;
  const explanation = await openaiService.generateExplanation(concept, req.user.cefrLevel || 'B1');
  return success(res, { explanation });
});

module.exports = router;
