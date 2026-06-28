const logger = require('../config/logger');
const { ApiResponse } = require('../utils/apiResponse');

/**
 * Global error handler middleware.
 * Must have 4 parameters to be recognized by Express as error middleware.
 */
// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  logger.error('Unhandled error:', {
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
    userId: req.user?.id,
    body: req.body,
  });

  // Sequelize validation errors
  if (err.name === 'SequelizeValidationError') {
    const errors = err.errors.map((e) => ({ field: e.path, message: e.message }));
    return ApiResponse.validationError(res, errors);
  }

  // Sequelize unique constraint
  if (err.name === 'SequelizeUniqueConstraintError') {
    const errors = err.errors.map((e) => ({
      field: e.path,
      message: `${e.path} already exists.`,
    }));
    return ApiResponse.conflict(res, 'Duplicate entry.', errors);
  }

  // Sequelize database errors
  if (err.name === 'SequelizeDatabaseError') {
    return ApiResponse.error(res, 'Database error occurred.', 500);
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return ApiResponse.unauthorized(res, 'Invalid token.');
  }

  if (err.name === 'TokenExpiredError') {
    return ApiResponse.unauthorized(res, 'Token has expired. Please log in again.');
  }

  // Multer errors
  if (err.code === 'LIMIT_FILE_SIZE') {
    return ApiResponse.badRequest(res, 'File size exceeds the allowed limit.');
  }

  // Custom app errors with statusCode
  if (err.statusCode) {
    return ApiResponse.error(res, err.message, err.statusCode);
  }

  // 404 Not Found
  if (err.status === 404) {
    return ApiResponse.notFound(res, err.message || 'Resource not found.');
  }

  // Default internal server error
  const isDev = process.env.NODE_ENV === 'development';
  return res.status(500).json({
    success: false,
    message: 'An unexpected error occurred.',
    ...(isDev && { error: err.message, stack: err.stack }),
  });
};

/**
 * 404 handler for unmatched routes.
 */
const notFoundHandler = (req, res) => {
  return ApiResponse.notFound(res, `Route ${req.method} ${req.path} not found.`);
};

module.exports = { errorHandler, notFoundHandler };
