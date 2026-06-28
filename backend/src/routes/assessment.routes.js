const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { Assessment } = require('../models');
const openaiService = require('../services/ai/openaiService');

router.post('/start', authenticate, async (req, res) => {
  const assessment = await Assessment.create({ userId: req.user.id, status: 'in_progress', startedAt: new Date() });
  return success(res, { assessmentId: assessment.id }, 'Assessment started');
});

router.post('/submit-writing', authenticate, async (req, res) => {
  const { assessmentId, text, topic } = req.body;
  const analysis = await openaiService.analyzeWriting(text, topic);
  await Assessment.update({ writingScore: analysis.score, writingFeedback: analysis.feedback }, { where: { id: assessmentId, userId: req.user.id } });
  return success(res, { analysis }, 'Writing submitted');
});

router.post('/submit-grammar', authenticate, async (req, res) => {
  const { assessmentId, answers } = req.body;
  const correct = answers.filter((a) => a.isCorrect).length;
  const score = Math.round((correct / answers.length) * 100);
  await Assessment.update({ grammarScore: score }, { where: { id: assessmentId, userId: req.user.id } });
  return success(res, { score }, 'Grammar submitted');
});

router.post('/complete', authenticate, async (req, res) => {
  const { assessmentId } = req.body;
  const assessment = await Assessment.findOne({ where: { id: assessmentId, userId: req.user.id } });
  const avgScore = [assessment.writingScore, assessment.grammarScore].filter(Boolean).reduce((a, b) => a + b, 0) / 2;
  const cefrLevel = require('../utils/cefr').scoreToCEFR(avgScore);
  const { ielts, toefl } = require('../utils/cefr').cefrToExamScores(cefrLevel);

  await assessment.update({ status: 'completed', completedAt: new Date(), overallScore: avgScore, cefrLevel });
  await req.user.update({ cefrLevel, ieltEstimate: ielts, toeflEstimate: toefl });

  return success(res, { cefrLevel, ielts, toefl, overallScore: avgScore }, 'Assessment completed');
});

router.get('/results/:id', authenticate, async (req, res) => {
  const assessment = await Assessment.findOne({ where: { id: req.params.id, userId: req.user.id } });
  if (!assessment) return res.status(404).json({ success: false, message: 'Not found' });
  return success(res, { assessment });
});

module.exports = router;
