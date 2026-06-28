const rateLimit = require('express-rate-limit');
const { getRedisClient } = require('../config/redis');
const { ApiResponse } = require('../utils/apiResponse');

const handler = (req, res) => {
  return ApiResponse.tooManyRequests(res, 'Too many requests. Please try again later.');
};

// General API rate limit
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  handler,
});

// Auth endpoints (login, register)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  handler,
  skipSuccessfulRequests: true,
});

// Password reset
const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  handler,
});

// AI endpoints (expensive operations)
const aiLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  handler,
});

// Audio upload endpoints
const audioLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  handler,
});

// Email verification / resend
const emailLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  handler,
});

// Admin endpoints
const adminLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  handler,
});

module.exports = {
  generalLimiter,
  authLimiter,
  passwordResetLimiter,
  aiLimiter,
  audioLimiter,
  emailLimiter,
  adminLimiter,
};
