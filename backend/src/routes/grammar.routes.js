const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');

const grammarTopics = [
  { id: 1, category: 'Tenses', title: 'Simple Present', level: 'A1', lessonCount: 5 },
  { id: 2, category: 'Tenses', title: 'Simple Past', level: 'A1', lessonCount: 5 },
  { id: 3, category: 'Tenses', title: 'Present Continuous', level: 'A2', lessonCount: 4 },
  { id: 4, category: 'Tenses', title: 'Present Perfect', level: 'B1', lessonCount: 6 },
  { id: 5, category: 'Tenses', title: 'Past Perfect', level: 'B1', lessonCount: 4 },
  { id: 6, category: 'Tenses', title: 'Future Tenses', level: 'B1', lessonCount: 5 },
  { id: 7, category: 'Modal Verbs', title: 'Can, Could, May', level: 'A2', lessonCount: 4 },
  { id: 8, category: 'Modal Verbs', title: 'Must, Should, Would', level: 'B1', lessonCount: 4 },
  { id: 9, category: 'Passive Voice', title: 'Passive Voice', level: 'B1', lessonCount: 5 },
  { id: 10, category: 'Conditionals', title: 'Zero & First Conditional', level: 'B1', lessonCount: 4 },
  { id: 11, category: 'Conditionals', title: 'Second & Third Conditional', level: 'B2', lessonCount: 4 },
  { id: 12, category: 'Reported Speech', title: 'Reported Speech', level: 'B2', lessonCount: 5 },
  { id: 13, category: 'Phrasal Verbs', title: 'Common Phrasal Verbs', level: 'B1', lessonCount: 8 },
  { id: 14, category: 'Articles', title: 'A, An, The', level: 'A2', lessonCount: 4 },
  { id: 15, category: 'Prepositions', title: 'Prepositions of Time & Place', level: 'A2', lessonCount: 5 },
];

router.get('/topics', authenticate, (req, res) => {
  const { category, level } = req.query;
  let filtered = grammarTopics;
  if (category) filtered = filtered.filter((t) => t.category === category);
  if (level) filtered = filtered.filter((t) => t.level === level);
  return success(res, { topics: filtered, categories: [...new Set(grammarTopics.map((t) => t.category))] });
});

router.get('/topics/:id', authenticate, (req, res) => {
  const topic = grammarTopics.find((t) => t.id === parseInt(req.params.id));
  if (!topic) return res.status(404).json({ success: false, message: 'Not found' });
  return success(res, { topic });
});

module.exports = router;
