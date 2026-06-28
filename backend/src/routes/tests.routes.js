const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { TestResult } = require('../models');

router.get('/', authenticate, async (req, res) => {
  const { type } = req.query; // mini, weekly, monthly, level, final
  const tests = [
    { id: 1, type: 'mini', title: 'Lesson 1 Quiz', levelId: 1, questionCount: 10, timeLimit: 300 },
    { id: 2, type: 'weekly', title: 'Week 1 Test', levelId: 1, questionCount: 25, timeLimit: 900 },
    { id: 3, type: 'level', title: 'Level 1 Exam', levelId: 1, questionCount: 50, timeLimit: 2700 },
  ];
  return success(res, { tests: type ? tests.filter((t) => t.type === type) : tests });
});

router.post('/:id/submit', authenticate, async (req, res) => {
  const { answers, timeSpent } = req.body;
  const score = Math.round(Math.random() * 40 + 60);
  const passed = score >= 70;

  const result = await TestResult.create({
    userId: req.user.id,
    testId: req.params.id,
    score,
    passed,
    timeSpent,
    answers,
  });

  return success(res, { result, score, passed, certificate: passed ? { url: `https://assets.smartenglish.com/certificates/${result.id}.pdf` } : null });
});

router.get('/results', authenticate, async (req, res) => {
  const results = await TestResult.findAll({ where: { userId: req.user.id }, order: [['createdAt', 'DESC']], limit: 20 });
  return success(res, { results });
});

module.exports = router;
