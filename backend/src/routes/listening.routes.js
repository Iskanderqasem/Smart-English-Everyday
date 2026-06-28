const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');

const audioLessons = [
  { id: 1, title: 'Daily Routines', accent: 'British', level: 'A2', duration: 90, audioUrl: 'https://assets.smartenglish.com/audio/daily-routines-uk.mp3', questions: [
    { id: 1, question: 'What time does the speaker wake up?', options: ['6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM'], correct: 1 },
    { id: 2, question: 'What does she have for breakfast?', options: ['Toast', 'Cereal', 'Eggs', 'Nothing'], correct: 0 },
  ]},
  { id: 2, title: 'At the Airport', accent: 'American', level: 'B1', duration: 120, audioUrl: 'https://assets.smartenglish.com/audio/airport-us.mp3', questions: [
    { id: 1, question: 'Where is the speaker flying to?', options: ['London', 'New York', 'Sydney', 'Toronto'], correct: 2 },
  ]},
  { id: 3, title: 'Job Interview', accent: 'Australian', level: 'B2', duration: 150, audioUrl: 'https://assets.smartenglish.com/audio/interview-au.mp3', questions: [
    { id: 1, question: 'What position is being discussed?', options: ['Manager', 'Developer', 'Designer', 'Analyst'], correct: 1 },
  ]},
];

router.get('/lessons', authenticate, (req, res) => {
  const { accent, level } = req.query;
  let filtered = audioLessons;
  if (accent) filtered = filtered.filter((l) => l.accent.toLowerCase() === accent.toLowerCase());
  if (level) filtered = filtered.filter((l) => l.level === level);
  return success(res, { lessons: filtered });
});

router.get('/lessons/:id', authenticate, (req, res) => {
  const lesson = audioLessons.find((l) => l.id === parseInt(req.params.id));
  if (!lesson) return res.status(404).json({ success: false, message: 'Not found' });
  return success(res, { lesson });
});

router.post('/lessons/:id/answer', authenticate, async (req, res) => {
  const { answers } = req.body;
  const lesson = audioLessons.find((l) => l.id === parseInt(req.params.id));
  if (!lesson) return res.status(404).json({ success: false, message: 'Not found' });

  const results = answers.map((a) => {
    const q = lesson.questions.find((q) => q.id === a.questionId);
    return { questionId: a.questionId, correct: q?.correct === a.selectedIndex, correctAnswer: q?.correct };
  });

  const score = Math.round((results.filter((r) => r.correct).length / results.length) * 100);
  return success(res, { results, score });
});

module.exports = router;
