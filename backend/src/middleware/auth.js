const passport = require('passport');
const { ApiResponse } = require('../utils/apiResponse');

/**
 * Authenticate request via JWT Bearer token.
 * Attaches the user object to req.user on success.
 */
const authenticate = (req, res, next) => {
  passport.authenticate('jwt', { session: false }, (err, user, info) => {
    if (err) {
      return next(err);
    }

    if (!user) {
      const message =
        info?.message || info?.name === 'TokenExpiredError'
          ? 'Token has expired. Please log in again.'
          : 'Unauthorized. Invalid or missing token.';

      return ApiResponse.unauthorized(res, message);
    }

    req.user = user;
    return next();
  })(req, res, next);
};

/**
 * Optional authentication - attaches user if token present, but does not block.
 */
const optionalAuth = (req, res, next) => {
  passport.authenticate('jwt', { session: false }, (err, user) => {
    if (!err && user) {
      req.user = user;
    }
    return next();
  })(req, res, next);
};

module.exports = { authenticate, optionalAuth };
