const { ApiResponse } = require('../utils/apiResponse');

/**
 * Role-based authorization middleware factory.
 * Usage: authorize('admin') or authorize('admin', 'teacher')
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return ApiResponse.unauthorized(res, 'Authentication required.');
    }

    if (!roles.includes(req.user.role)) {
      return ApiResponse.forbidden(
        res,
        `Access denied. Required role(s): ${roles.join(', ')}. Your role: ${req.user.role}.`
      );
    }

    return next();
  };
};

/**
 * Check if user is accessing their own resource or is an admin.
 * Expects :userId in route params.
 */
const authorizeOwnerOrAdmin = (req, res, next) => {
  if (!req.user) {
    return ApiResponse.unauthorized(res, 'Authentication required.');
  }

  const resourceUserId = req.params.userId || req.params.id;

  if (req.user.id === resourceUserId || req.user.role === 'admin') {
    return next();
  }

  return ApiResponse.forbidden(res, 'Access denied. You can only access your own resources.');
};

/**
 * Verify email before allowing access to protected features.
 */
const requireEmailVerified = (req, res, next) => {
  if (!req.user) {
    return ApiResponse.unauthorized(res, 'Authentication required.');
  }

  if (!req.user.isEmailVerified) {
    return ApiResponse.forbidden(
      res,
      'Email verification required. Please verify your email address.'
    );
  }

  return next();
};

module.exports = { authorize, authorizeOwnerOrAdmin, requireEmailVerified };
