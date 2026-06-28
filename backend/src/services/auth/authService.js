const { User } = require('../../models');
const { hashPassword, comparePassword } = require('../../utils/passwordUtils');
const { generateToken, verifyToken } = require('../../utils/tokenUtils');
const emailService = require('../email/emailService');
const { OAuth2Client } = require('google-auth-library');
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');
const crypto = require('crypto');
const { Op } = require('sequelize');

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const findByEmailOrUsername = async (email, username) => {
  return User.findOne({
    where: { [Op.or]: [{ email: email || '' }, { username: username || '' }] },
  });
};

const register = async ({ firstName, lastName, username, email, password, englishVariant }) => {
  const hashedPassword = await hashPassword(password);
  const verificationToken = crypto.randomBytes(32).toString('hex');

  return User.create({
    firstName,
    lastName,
    username,
    email,
    password: hashedPassword,
    englishVariant,
    emailVerificationToken: verificationToken,
    emailVerificationExpires: new Date(Date.now() + 24 * 60 * 60 * 1000),
  });
};

const verifyPassword = async (plain, hashed) => comparePassword(plain, hashed);

const sendVerificationEmail = async (user) => {
  const url = `${process.env.FRONTEND_URL}/verify-email/${user.emailVerificationToken}`;
  await emailService.sendVerificationEmail(user.email, user.firstName, url);
};

const verifyEmail = async (token) => {
  const user = await User.findOne({
    where: {
      emailVerificationToken: token,
      emailVerificationExpires: { [Op.gt]: new Date() },
    },
  });
  if (!user) throw new Error('Invalid or expired verification token');
  await user.update({ isEmailVerified: true, emailVerificationToken: null, emailVerificationExpires: null });
  return user;
};

const googleLogin = async (googleToken) => {
  const ticket = await googleClient.verifyIdToken({ idToken: googleToken, audience: process.env.GOOGLE_CLIENT_ID });
  const payload = ticket.getPayload();

  let user = await User.findOne({ where: { googleId: payload.sub } });
  let isNew = false;

  if (!user) {
    user = await User.findOne({ where: { email: payload.email } });
    if (user) {
      await user.update({ googleId: payload.sub });
    } else {
      user = await User.create({
        googleId: payload.sub,
        email: payload.email,
        firstName: payload.given_name,
        lastName: payload.family_name,
        avatar: payload.picture,
        isEmailVerified: true,
        username: payload.email.split('@')[0] + Math.floor(Math.random() * 1000),
        englishVariant: 'US',
      });
      isNew = true;
    }
  }

  await user.update({ lastLoginAt: new Date() });
  return { user, isNew };
};

const facebookLogin = async (accessToken) => {
  const response = await fetch(`https://graph.facebook.com/me?fields=id,name,email,picture&access_token=${accessToken}`);
  const data = await response.json();

  let user = await User.findOne({ where: { facebookId: data.id } });
  let isNew = false;

  if (!user) {
    user = await User.findOne({ where: { email: data.email } });
    if (user) {
      await user.update({ facebookId: data.id });
    } else {
      const [firstName, ...lastParts] = data.name.split(' ');
      user = await User.create({
        facebookId: data.id,
        email: data.email,
        firstName,
        lastName: lastParts.join(' '),
        avatar: data.picture?.data?.url,
        isEmailVerified: true,
        username: data.email ? data.email.split('@')[0] + Math.floor(Math.random() * 1000) : `user${Date.now()}`,
        englishVariant: 'US',
      });
      isNew = true;
    }
  }

  await user.update({ lastLoginAt: new Date() });
  return { user, isNew };
};

const forgotPassword = async (email) => {
  const user = await User.findOne({ where: { email } });
  if (!user) return;

  const resetToken = crypto.randomBytes(32).toString('hex');
  const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');

  await user.update({
    passwordResetToken: hashedToken,
    passwordResetExpires: new Date(Date.now() + 60 * 60 * 1000),
  });

  const resetUrl = `${process.env.FRONTEND_URL}/reset-password/${resetToken}`;
  await emailService.sendPasswordResetEmail(user.email, user.firstName, resetUrl);
};

const resetPassword = async (token, newPassword) => {
  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');
  const user = await User.findOne({
    where: {
      passwordResetToken: hashedToken,
      passwordResetExpires: { [Op.gt]: new Date() },
    },
  });

  if (!user) throw new Error('Invalid or expired reset token');

  const hashedPassword = await hashPassword(newPassword);
  await user.update({ password: hashedPassword, passwordResetToken: null, passwordResetExpires: null });
};

const refreshToken = async (token) => {
  const decoded = verifyToken(token, process.env.JWT_REFRESH_SECRET);
  const user = await User.findByPk(decoded.id);
  if (!user) throw new Error('User not found');

  const newToken = generateToken(user.id);
  const newRefreshToken = generateToken(user.id, process.env.JWT_REFRESH_SECRET, process.env.JWT_REFRESH_EXPIRES);

  return { token: newToken, newRefreshToken };
};

const logout = async (userId, token) => {
  // In production, add token to a blocklist in Redis
  return true;
};

const setup2FA = async (userId) => {
  const user = await User.findByPk(userId);
  const secret = speakeasy.generateSecret({ name: `Smart English Everyday (${user.email})` });
  await user.update({ twoFactorSecret: secret.base32 });

  const qrCode = await QRCode.toDataURL(secret.otpauth_url);
  return { secret: secret.base32, qrCode };
};

const verify2FA = async (userId, token) => {
  const user = await User.findByPk(userId);
  const verified = speakeasy.totp.verify({ secret: user.twoFactorSecret, encoding: 'base32', token, window: 2 });
  if (!verified) throw new Error('Invalid 2FA code');
  await user.update({ twoFactorEnabled: true });
};

const disable2FA = async (userId, token) => {
  const user = await User.findByPk(userId);
  const verified = speakeasy.totp.verify({ secret: user.twoFactorSecret, encoding: 'base32', token, window: 2 });
  if (!verified) throw new Error('Invalid 2FA code');
  await user.update({ twoFactorEnabled: false, twoFactorSecret: null });
};

const verifyTwoFactorLogin = async (tempToken, code) => {
  const decoded = verifyToken(tempToken, process.env.JWT_SECRET);
  const user = await User.findByPk(decoded.id);
  if (!user) throw new Error('User not found');

  const verified = speakeasy.totp.verify({ secret: user.twoFactorSecret, encoding: 'base32', token: code, window: 2 });
  if (!verified) throw new Error('Invalid 2FA code');

  await user.update({ lastLoginAt: new Date() });
  return { user };
};

module.exports = { findByEmailOrUsername, register, verifyPassword, sendVerificationEmail, verifyEmail, googleLogin, facebookLogin, forgotPassword, resetPassword, refreshToken, logout, setup2FA, verify2FA, disable2FA, verifyTwoFactorLogin };
