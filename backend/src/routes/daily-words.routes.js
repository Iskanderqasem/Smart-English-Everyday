const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { Word } = require('../models');
const { redisClient } = require('../config/redis');

router.get('/today', authenticate, async (req, res) => {
  const cacheKey = `daily-word:${new Date().toISOString().split('T')[0]}`;
  const cached = await redisClient.get(cacheKey);

  if (cached) return success(res, { word: JSON.parse(cached) });

  const word = await Word.findOne({ order: require('sequelize').literal('random()') });
  await redisClient.setEx(cacheKey, 86400, JSON.stringify(word));

  return success(res, { word });
});

router.get('/history', authenticate, async (req, res) => {
  const words = await Word.findAll({ order: [['createdAt', 'DESC']], limit: 30 });
  return success(res, { words });
});

router.post('/quiz', authenticate, async (req, res) => {
  const { wordId, selectedDefinition } = req.body;
  const word = await Word.findByPk(wordId);
  const correct = word?.definition === selectedDefinition;
  return success(res, { correct, xpEarned: correct ? 10 : 0 });
});

module.exports = router;
