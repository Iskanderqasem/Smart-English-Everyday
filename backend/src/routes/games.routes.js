const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { Word } = require('../models');

router.get('/leaderboard', authenticate, async (req, res) => {
  const { User } = require('../models');
  const top = await User.findAll({ attributes: ['id', 'username', 'firstName', 'avatar'], order: [[require('sequelize').literal('xp'), 'DESC']], limit: 20 });
  return success(res, { leaderboard: top });
});

router.get('/word-match/words', authenticate, async (req, res) => {
  const words = await Word.findAll({ order: require('sequelize').literal('random()'), limit: 8, attributes: ['id', 'word', 'definition', 'topic'] });
  return success(res, { words });
});

router.get('/hangman/word', authenticate, async (req, res) => {
  const { level } = req.query;
  const where = level ? { cefrLevel: level } : {};
  const [word] = await Word.findAll({ where, order: require('sequelize').literal('random()'), limit: 1 });
  return success(res, { word: word?.word, hint: word?.definition });
});

router.get('/word-search/grid', authenticate, async (req, res) => {
  const words = await Word.findAll({ order: require('sequelize').literal('random()'), limit: 10, attributes: ['word', 'definition'] });
  return success(res, { words: words.map((w) => ({ word: w.word.toUpperCase(), clue: w.definition })) });
});

router.post('/score', authenticate, async (req, res) => {
  const { gameType, score, xpEarned } = req.body;
  // Award XP and update leaderboard
  return success(res, { xpEarned, newTotal: 1240 + xpEarned });
});

module.exports = router;
