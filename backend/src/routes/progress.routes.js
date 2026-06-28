const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const progressService = require('../services/progress/progressService');

router.get('/summary', authenticate, async (req, res) => {
  const summary = await progressService.getProgressSummary(req.user.id);
  return success(res, { summary });
});

router.get('/weekly', authenticate, async (req, res) => {
  const report = await progressService.generateWeeklyReport(req.user.id);
  return success(res, { report });
});

router.get('/streak', authenticate, async (req, res) => {
  const streak = await progressService.calculateStreak(req.user.id);
  return success(res, { streak });
});

router.get('/achievements', authenticate, async (req, res) => {
  const { UserAchievement, Achievement } = require('../models');
  const achievements = await UserAchievement.findAll({
    where: { userId: req.user.id },
    include: [Achievement],
  });
  return success(res, { achievements });
});

module.exports = router;
