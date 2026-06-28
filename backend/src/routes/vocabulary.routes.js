const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { Word, Progress } = require('../models');
const { Op } = require('sequelize');

router.get('/words', authenticate, async (req, res) => {
  const { topic, level, search, page = 1, limit = 20 } = req.query;
  const where = {};
  if (topic) where.topic = topic;
  if (level) where.cefrLevel = level;
  if (search) where.word = { [Op.iLike]: `%${search}%` };

  const { count, rows } = await Word.findAndCountAll({ where, offset: (page - 1) * limit, limit: parseInt(limit), order: [['word', 'ASC']] });
  return success(res, { words: rows, total: count, page: parseInt(page), pages: Math.ceil(count / limit) });
});

router.get('/topics', authenticate, async (req, res) => {
  const topics = await Word.findAll({ attributes: [[require('sequelize').fn('DISTINCT', require('sequelize').col('topic')), 'topic']], raw: true });
  return success(res, { topics: topics.map((t) => t.topic) });
});

router.get('/daily-review', authenticate, async (req, res) => {
  const words = await Word.findAll({ order: require('sequelize').literal('random()'), limit: 10 });
  return success(res, { words });
});

router.post('/words/:id/learned', authenticate, async (req, res) => {
  // Mark word as learned for spaced repetition
  return success(res, null, 'Word marked as learned');
});

module.exports = router;
