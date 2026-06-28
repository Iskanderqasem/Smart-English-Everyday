const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { authorize } = require('../middleware/authorize');
const { success } = require('../utils/apiResponse');
const { User, Progress, Assessment, TestResult } = require('../models');
const { Op } = require('sequelize');
const sequelize = require('sequelize');

router.use(authenticate, authorize('admin'));

router.get('/dashboard', async (req, res) => {
  const now = new Date();
  const startOfDay = new Date(now.setHours(0, 0, 0, 0));
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  const [total, active, newToday, newThisMonth] = await Promise.all([
    User.count({ where: { role: 'student' } }),
    User.count({ where: { role: 'student', lastLoginAt: { [Op.gte]: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } } }),
    User.count({ where: { createdAt: { [Op.gte]: startOfDay } } }),
    User.count({ where: { createdAt: { [Op.gte]: startOfMonth } } }),
  ]);

  return success(res, { stats: { totalStudents: total, activeStudents: active, newToday, newThisMonth } });
});

router.get('/users', async (req, res) => {
  const { page = 1, limit = 20, search, role, status } = req.query;
  const where = {};
  if (search) where[Op.or] = [{ email: { [Op.iLike]: `%${search}%` } }, { username: { [Op.iLike]: `%${search}%` } }];
  if (role) where.role = role;
  if (status === 'active') where.isActive = true;
  if (status === 'inactive') where.isActive = false;

  const { count, rows } = await User.findAndCountAll({ where, attributes: { exclude: ['password', 'twoFactorSecret'] }, offset: (page - 1) * limit, limit: parseInt(limit), order: [['createdAt', 'DESC']] });
  return success(res, { users: rows, total: count, page: parseInt(page), pages: Math.ceil(count / limit) });
});

router.get('/users/:id', async (req, res) => {
  const user = await User.findByPk(req.params.id, { attributes: { exclude: ['password', 'twoFactorSecret'] } });
  if (!user) return res.status(404).json({ success: false, message: 'Not found' });
  return success(res, { user });
});

router.put('/users/:id/status', async (req, res) => {
  const { isActive } = req.body;
  await User.update({ isActive }, { where: { id: req.params.id } });
  return success(res, null, `User ${isActive ? 'activated' : 'deactivated'}`);
});

router.get('/analytics', async (req, res) => {
  const cefrDistribution = await User.findAll({
    attributes: ['cefrLevel', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
    where: { role: 'student', cefrLevel: { [Op.ne]: null } },
    group: ['cefrLevel'],
    raw: true,
  });
  return success(res, { cefrDistribution });
});

router.post('/notifications/broadcast', async (req, res) => {
  const { title, body, topic } = req.body;
  const notificationService = require('../services/notification/notificationService');
  await notificationService.broadcastToAll(title, body);
  return success(res, null, 'Broadcast sent');
});

module.exports = router;
