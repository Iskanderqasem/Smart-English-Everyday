const authService = require('../services/auth/authService');
const { success, error } = require('../utils/apiResponse');
const { generateToken, generateRefreshToken } = require('../utils/tokenUtils');

const register = async (req, res) => {
  const { firstName, lastName, username, email, password, englishVariant } = req.body;

  const existingUser = await authService.findByEmailOrUsername(email, username);
  if (existingUser) {
    return error(res, 'Email or username already in use', 409);
  }

  const user = await authService.register({ firstName, lastName, username, email, password, englishVariant });
  await authService.sendVerificationEmail(user);

  const token = generateToken(user.id);
  const refreshToken = generateRefreshToken(user.id);

  return success(res, { user: user.toSafeJSON(), token, refreshToken }, 'Registration successful. Please verify your email.', 201);
};

const login = async (req, res) => {
  const { emailOrUsername, password } = req.body;

  const user = await authService.findByEmailOrUsername(emailOrUsername, emailOrUsername);
  if (!user) return error(res, 'Invalid credentials', 401);

  const isPasswordValid = await authService.verifyPassword(password, user.password);
  if (!isPasswordValid) return error(res, 'Invalid credentials', 401);

  if (!user.isActive) return error(res, 'Account has been deactivated', 403);

  if (user.twoFactorEnabled) {
    const tempToken = generateToken(user.id, '5m');
    return success(res, { requiresTwoFactor: true, tempToken }, 'Two-factor authentication required');
  }

  await user.update({ lastLoginAt: new Date() });

  const token = generateToken(user.id);
  const refreshToken = generateRefreshToken(user.id);

  return success(res, { user: user.toSafeJSON(), token, refreshToken }, 'Login successful');
};

const googleLogin = async (req, res) => {
  const { googleToken } = req.body;
  const { user, isNew } = await authService.googleLogin(googleToken);

  const token = generateToken(user.id);
  const refreshToken = generateRefreshToken(user.id);

  return success(res, { user: user.toSafeJSON(), token, refreshToken, isNew }, isNew ? 'Account created' : 'Login successful');
};

const facebookLogin = async (req, res) => {
  const { accessToken } = req.body;
  const { user, isNew } = await authService.facebookLogin(accessToken);

  const token = generateToken(user.id);
  const refreshToken = generateRefreshToken(user.id);

  return success(res, { user: user.toSafeJSON(), token, refreshToken, isNew }, isNew ? 'Account created' : 'Login successful');
};

const verifyEmail = async (req, res) => {
  const { token } = req.params;
  await authService.verifyEmail(token);
  return success(res, null, 'Email verified successfully');
};

const forgotPassword = async (req, res) => {
  const { email } = req.body;
  await authService.forgotPassword(email);
  return success(res, null, 'If that email exists, a reset link has been sent');
};

const resetPassword = async (req, res) => {
  const { token, newPassword } = req.body;
  await authService.resetPassword(token, newPassword);
  return success(res, null, 'Password reset successfully');
};

const refreshToken = async (req, res) => {
  const { refreshToken: rt } = req.body;
  const { token, newRefreshToken } = await authService.refreshToken(rt);
  return success(res, { token, refreshToken: newRefreshToken }, 'Token refreshed');
};

const logout = async (req, res) => {
  await authService.logout(req.user.id, req.body.refreshToken);
  return success(res, null, 'Logged out successfully');
};

const getMe = async (req, res) => {
  return success(res, { user: req.user.toSafeJSON() });
};

const setup2FA = async (req, res) => {
  const { secret, qrCode } = await authService.setup2FA(req.user.id);
  return success(res, { secret, qrCode }, '2FA setup initiated');
};

const verify2FA = async (req, res) => {
  const { token } = req.body;
  await authService.verify2FA(req.user.id, token);
  return success(res, null, '2FA enabled successfully');
};

const disable2FA = async (req, res) => {
  const { token } = req.body;
  await authService.disable2FA(req.user.id, token);
  return success(res, null, '2FA disabled');
};

const verifyTwoFactor = async (req, res) => {
  const { tempToken, code } = req.body;
  const { user } = await authService.verifyTwoFactorLogin(tempToken, code);

  const token = generateToken(user.id);
  const refreshToken = generateRefreshToken(user.id);

  return success(res, { user: user.toSafeJSON(), token, refreshToken }, 'Login successful');
};

module.exports = { register, login, googleLogin, facebookLogin, verifyEmail, forgotPassword, resetPassword, refreshToken, logout, getMe, setup2FA, verify2FA, disable2FA, verifyTwoFactor };
