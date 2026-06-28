const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth');
const { success } = require('../utils/apiResponse');
const { Notification } = require('../models');

router.get('/', authenticate, async (req, res) => {
  const notifications = await Notification.findAll({ where: { userId: req.user.id }, order: [['createdAt', 'DESC']], limit: 50 });
  return success(res, { notifications });
});

router.post('/register-token', authenticate, async (req, res) => {
  const { fcmToken, platform } = req.body;
  await req.user.update({ fcmToken, fcmPlatform: platform });
  return success(res, null, 'Token registered');
});

router.put('/:id/read', authenticate, async (req, res) => {
  await Notification.update({ isRead: true }, { where: { id: req.params.id, userId: req.user.id } });
  return success(res, null, 'Marked as read');
});

router.put('/read-all', authenticate, async (req, res) => {
  await Notification.update({ isRead: true }, { where: { userId: req.user.id } });
  return success(res, null, 'All marked as read');
});

module.exports = router;
