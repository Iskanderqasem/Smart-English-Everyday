const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const openaiService = require('../services/ai/openaiService');
const { ChatMessage } = require('../models');

router.get('/topics', authenticate, (req, res) => {
  const topics = [
    { id: 'travel', name: 'Travel', icon: '✈️', description: 'Discuss travel plans, destinations, hotels' },
    { id: 'business', name: 'Business', icon: '💼', description: 'Professional conversations and meetings' },
    { id: 'daily_life', name: 'Daily Life', icon: '🏠', description: 'Everyday situations and routines' },
    { id: 'technology', name: 'Technology', icon: '💻', description: 'Tech news and digital life' },
    { id: 'health', name: 'Health', icon: '🏥', description: 'Medical vocabulary and healthy living' },
    { id: 'shopping', name: 'Shopping', icon: '🛍️', description: 'Shopping scenarios and bargaining' },
    { id: 'sports', name: 'Sports', icon: '⚽', description: 'Sports, fitness and recreation' },
    { id: 'education', name: 'Education', icon: '📚', description: 'School, university and learning' },
  ];
  return success(res, { topics });
});

router.post('/message', authenticate, async (req, res) => {
  const { message, topic, sessionId } = req.body;

  await ChatMessage.create({ userId: req.user.id, sessionType: 'chatbot', role: 'user', content: message, sessionId, topic });

  const history = await ChatMessage.findAll({
    where: { userId: req.user.id, sessionType: 'chatbot', sessionId },
    order: [['createdAt', 'ASC']],
    limit: 15,
  });

  const aiResponse = await openaiService.generateConversation(topic, message, history.map((m) => ({ role: m.role, content: m.content })), req.user.cefrLevel || 'B1');

  const aiMsg = await ChatMessage.create({ userId: req.user.id, sessionType: 'chatbot', role: 'assistant', content: aiResponse, sessionId, topic });
  return success(res, { message: aiMsg });
});

module.exports = router;
