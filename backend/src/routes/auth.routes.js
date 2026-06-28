const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');
const { validate } = require('../middleware/validate');
const { authLimiter } = require('../middleware/rateLimiter');
const Joi = require('joi');

const registerSchema = Joi.object({
  firstName: Joi.string().min(2).max(50).required(),
  lastName: Joi.string().min(2).max(50).required(),
  username: Joi.string().alphanum().min(3).max(30).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).required()
    .messages({ 'string.pattern.base': 'Password must contain uppercase, lowercase and number' }),
  englishVariant: Joi.string().valid('UK', 'US', 'AU', 'NZ', 'CA').default('US'),
});

const loginSchema = Joi.object({
  emailOrUsername: Joi.string().required(),
  password: Joi.string().required(),
});

const forgotPasswordSchema = Joi.object({ email: Joi.string().email().required() });
const resetPasswordSchema = Joi.object({ token: Joi.string().required(), newPassword: Joi.string().min(8).required() });

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Auth]
 */
router.post('/register', authLimiter, validate(registerSchema), authController.register);

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Login with email/username and password
 *     tags: [Auth]
 */
router.post('/login', authLimiter, validate(loginSchema), authController.login);

router.post('/google', authLimiter, authController.googleLogin);
router.post('/facebook', authLimiter, authController.facebookLogin);
router.get('/verify-email/:token', authController.verifyEmail);
router.post('/forgot-password', authLimiter, validate(forgotPasswordSchema), authController.forgotPassword);
router.post('/reset-password', validate(resetPasswordSchema), authController.resetPassword);
router.post('/refresh-token', authController.refreshToken);
router.post('/logout', authenticate, authController.logout);
router.get('/me', authenticate, authController.getMe);
router.post('/2fa/setup', authenticate, authController.setup2FA);
router.post('/2fa/verify', authenticate, authController.verify2FA);
router.post('/2fa/disable', authenticate, authController.disable2FA);
router.post('/2fa/login', authController.verifyTwoFactor);

module.exports = router;
