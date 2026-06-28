const { ApiResponse } = require('../utils/apiResponse');

/**
 * Joi validation middleware factory.
 * @param {Object} schema - Joi schema with optional body, params, query keys
 * @param {Object} options - Joi validation options
 */
const validate = (schema, options = {}) => {
  return (req, res, next) => {
    const defaultOptions = {
      abortEarly: false,
      allowUnknown: false,
      stripUnknown: true,
      ...options,
    };

    const errors = [];

    if (schema.body) {
      const { error, value } = schema.body.validate(req.body, defaultOptions);
      if (error) {
        errors.push(...error.details.map((d) => ({ field: d.path.join('.'), message: d.message })));
      } else {
        req.body = value;
      }
    }

    if (schema.params) {
      const { error, value } = schema.params.validate(req.params, defaultOptions);
      if (error) {
        errors.push(
          ...error.details.map((d) => ({
            field: `params.${d.path.join('.')}`,
            message: d.message,
          }))
        );
      } else {
        req.params = value;
      }
    }

    if (schema.query) {
      const { error, value } = schema.query.validate(req.query, {
        ...defaultOptions,
        allowUnknown: true,
      });
      if (error) {
        errors.push(
          ...error.details.map((d) => ({
            field: `query.${d.path.join('.')}`,
            message: d.message,
          }))
        );
      } else {
        req.query = value;
      }
    }

    if (errors.length > 0) {
      return ApiResponse.validationError(res, errors);
    }

    return next();
  };
};

module.exports = { validate };
