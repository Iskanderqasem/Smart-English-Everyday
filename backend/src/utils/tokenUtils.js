const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const JWT_SECRET = process.env.JWT_SECRET || 'change-me-in-production';
const JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'change-me-refresh-in-production';
const JWT_ISSUER = process.env.JWT_ISSUER || 'smart-english-everyday';
const JWT_AUDIENCE = process.env.JWT_AUDIENCE || 'smart-english-everyday-users';

/**
 * Generate a signed access token.
 */
const generateAccessToken = (user) => {
  return jwt.sign(
    {
      sub: user.id,
      email: user.email,
      role: user.role,
      username: user.username,
    },
    JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '15m',
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE,
    }
  );
};

/**
 * Generate a refresh token.
 */
const generateRefreshToken = (user) => {
  return jwt.sign(
    {
      sub: user.id,
      type: 'refresh',
    },
    JWT_REFRESH_SECRET,
    {
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE,
    }
  );
};

/**
 * Verify an access token.
 */
const verifyAccessToken = (token) => {
  return jwt.verify(token, JWT_SECRET, {
    issuer: JWT_ISSUER,
    audience: JWT_AUDIENCE,
  });
};

/**
 * Verify a refresh token.
 */
const verifyRefreshToken = (token) => {
  return jwt.verify(token, JWT_REFRESH_SECRET, {
    issuer: JWT_ISSUER,
    audience: JWT_AUDIENCE,
  });
};

/**
 * Generate a cryptographically secure random token.
 */
const generateSecureToken = (bytes = 32) => {
  return crypto.randomBytes(bytes).toString('hex');
};

/**
 * Hash a token for storage (email verification, password reset).
 */
const hashToken = (token) => {
  return crypto.createHash('sha256').update(token).digest('hex');
};

/**
 * Generate token pair (access + refresh).
 */
const generateTokenPair = (user) => {
  return {
    accessToken: generateAccessToken(user),
    refreshToken: generateRefreshToken(user),
    tokenType: 'Bearer',
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
  };
};

module.exports = {
  generateAccessToken,
  generateRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  generateSecureToken,
  hashToken,
  generateTokenPair,
};
