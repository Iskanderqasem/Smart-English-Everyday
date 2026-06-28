const bcrypt = require('bcryptjs');
const crypto = require('crypto');

const SALT_ROUNDS = parseInt(process.env.BCRYPT_SALT_ROUNDS, 10) || 12;

/**
 * Hash a plain-text password.
 */
const hashPassword = async (password) => {
  return bcrypt.hash(password, SALT_ROUNDS);
};

/**
 * Compare a plain-text password with a hash.
 */
const comparePassword = async (password, hash) => {
  return bcrypt.compare(password, hash);
};

/**
 * Generate a secure random password reset token.
 * Returns both the raw token (to send via email) and the hashed version (to store).
 */
const generatePasswordResetToken = () => {
  const token = crypto.randomBytes(32).toString('hex');
  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');
  const expires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
  return { token, hashedToken, expires };
};

/**
 * Hash a raw token for database lookup.
 */
const hashToken = (token) => {
  return crypto.createHash('sha256').update(token).digest('hex');
};

/**
 * Validate password strength.
 * Returns { valid, errors }
 */
const validatePasswordStrength = (password) => {
  const errors = [];

  if (password.length < 8) errors.push('Password must be at least 8 characters long.');
  if (!/[A-Z]/.test(password)) errors.push('Password must contain at least one uppercase letter.');
  if (!/[a-z]/.test(password)) errors.push('Password must contain at least one lowercase letter.');
  if (!/[0-9]/.test(password)) errors.push('Password must contain at least one number.');
  if (!/[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]/.test(password)) {
    errors.push('Password must contain at least one special character.');
  }

  return { valid: errors.length === 0, errors };
};

module.exports = {
  hashPassword,
  comparePassword,
  generatePasswordResetToken,
  hashToken,
  validatePasswordStrength,
};
