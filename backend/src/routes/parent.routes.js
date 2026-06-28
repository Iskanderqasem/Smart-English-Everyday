const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { authorize } = require('../middleware/authorize');
const { success } = require('../utils/apiResponse');
const { User, Progress, TestResult } = require('../models');

router.use(authenticate);

router.get('/children', async (req, res) => {
  // Fetch children linked to this parent account
  const children = await User.findAll({
    where: { parentId: req.user.id },
    attributes: { exclude: ['password', 'twoFactorSecret'] },
  });
  return success(res, { children });
});

router.post('/add-child', async (req, res) => {
  const { childEmail } = req.body;
  const child = await User.findOne({ where: { email: childEmail, role: 'student' } });
  if (!child) return res.status(404).json({ success: false, message: 'Student not found' });
  await child.update({ parentId: req.user.id });
  return success(res, { child: child.toSafeJSON() }, 'Child linked successfully');
});

router.get('/child/:id/progress', async (req, res) => {
  const child = await User.findOne({ where: { id: req.params.id, parentId: req.user.id } });
  if (!child) return res.status(403).json({ success: false, message: 'Access denied' });

  const progressService = require('../services/progress/progressService');
  const summary = await progressService.getProgressSummary(child.id);
  return success(res, { child: child.toSafeJSON(), progress: summary });
});

module.exports = router;
