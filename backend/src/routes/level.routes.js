const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { Level, Lesson, Progress } = require('../models');

router.get('/', authenticate, async (req, res) => {
  const levels = await Level.findAll({ order: [['number', 'ASC']], include: [{ model: Lesson, attributes: ['id', 'title', 'type', 'orderIndex'] }] });
  const progress = await Progress.findAll({ where: { userId: req.user.id } });
  const progressMap = Object.fromEntries(progress.map((p) => [p.levelId, p]));
  const data = levels.map((l) => ({ ...l.toJSON(), userProgress: progressMap[l.id] || null }));
  return success(res, { levels: data });
});

router.get('/:id', authenticate, async (req, res) => {
  const level = await Level.findByPk(req.params.id, { include: [Lesson] });
  if (!level) return res.status(404).json({ success: false, message: 'Level not found' });
  return success(res, { level });
});

module.exports = router;
