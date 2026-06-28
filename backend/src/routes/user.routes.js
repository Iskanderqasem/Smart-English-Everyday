const express = require('express');
const router = express.Router();
const { authenticate, authorize } = require('../middleware/auth');
const { upload } = require('../middleware/upload');

const getProfile = async (req, res) => {
  const { success } = require('../utils/apiResponse');
  return success(res, { user: req.user.toSafeJSON() });
};

const updateProfile = async (req, res) => {
  const { success } = require('../utils/apiResponse');
  const { firstName, lastName, username, englishVariant, bio } = req.body;
  await req.user.update({ firstName, lastName, username, englishVariant, bio });
  return success(res, { user: req.user.toSafeJSON() }, 'Profile updated');
};

const updateAvatar = async (req, res) => {
  const { success } = require('../utils/apiResponse');
  const s3Service = require('../services/storage/s3Service');
  if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });
  const avatarUrl = await s3Service.uploadImage(req.file.buffer, `avatars/${req.user.id}`, req.file.mimetype);
  await req.user.update({ avatar: avatarUrl });
  return success(res, { avatar: avatarUrl }, 'Avatar updated');
};

const changePassword = async (req, res) => {
  const { success, error } = require('../utils/apiResponse');
  const { comparePassword, hashPassword } = require('../utils/passwordUtils');
  const { currentPassword, newPassword } = req.body;
  const isValid = await comparePassword(currentPassword, req.user.password);
  if (!isValid) return error(res, 'Current password is incorrect', 400);
  await req.user.update({ password: await hashPassword(newPassword) });
  return success(res, null, 'Password changed successfully');
};

router.get('/profile', authenticate, getProfile);
router.put('/profile', authenticate, updateProfile);
router.post('/profile/avatar', authenticate, upload.single('avatar'), updateAvatar);
router.post('/change-password', authenticate, changePassword);

module.exports = router;
