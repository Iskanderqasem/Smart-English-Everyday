const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { Lesson, Exercise, Progress } = require('../models');

router.get('/', authenticate, async (req, res) => {
  const { levelId, type } = req.query;
  const where = {};
  if (levelId) where.levelId = levelId;
  if (type) where.type = type;
  const lessons = await Lesson.findAll({ where, order: [['orderIndex', 'ASC']] });
  return success(res, { lessons });
});

router.get('/:id', authenticate, async (req, res) => {
  const lesson = await Lesson.findByPk(req.params.id, { include: [Exercise] });
  if (!lesson) return res.status(404).json({ success: false, message: 'Not found' });
  return success(res, { lesson });
});

router.post('/:id/complete', authenticate, async (req, res) => {
  const { score, timeSpent } = req.body;
  const lesson = await Lesson.findByPk(req.params.id);
  if (!lesson) return res.status(404).json({ success: false, message: 'Not found' });

  const progressService = require('../services/progress/progressService');
  await progressService.updateProgress(req.user.id, lesson.levelId, lesson.id, score, timeSpent);

  return success(res, null, 'Lesson completed');
});

module.exports = router;
