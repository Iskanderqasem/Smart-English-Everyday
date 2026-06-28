/**
 * Standardized API response helper.
 */
class ApiResponse {
  static success(res, message = 'Success', data = null, statusCode = 200) {
    const response = { success: true, message };
    if (data !== null && data !== undefined) response.data = data;
    return res.status(statusCode).json(response);
  }

  static created(res, message = 'Created successfully', data = null) {
    return ApiResponse.success(res, message, data, 201);
  }

  static paginated(res, message, data, pagination) {
    return res.status(200).json({
      success: true,
      message,
      data,
      pagination,
    });
  }

  static error(res, message = 'An error occurred', statusCode = 500, errors = null) {
    const response = { success: false, message };
    if (errors) response.errors = errors;
    return res.status(statusCode).json(response);
  }

  static badRequest(res, message = 'Bad request', errors = null) {
    return ApiResponse.error(res, message, 400, errors);
  }

  static unauthorized(res, message = 'Unauthorized') {
    return ApiResponse.error(res, message, 401);
  }

  static forbidden(res, message = 'Forbidden') {
    return ApiResponse.error(res, message, 403);
  }

  static notFound(res, message = 'Resource not found') {
    return ApiResponse.error(res, message, 404);
  }

  static conflict(res, message = 'Conflict', errors = null) {
    return ApiResponse.error(res, message, 409, errors);
  }

  static validationError(res, errors, message = 'Validation failed') {
    return res.status(422).json({
      success: false,
      message,
      errors,
    });
  }

  static tooManyRequests(res, message = 'Too many requests') {
    return ApiResponse.error(res, message, 429);
  }

  static serviceUnavailable(res, message = 'Service temporarily unavailable') {
    return ApiResponse.error(res, message, 503);
  }

  /**
   * Build pagination metadata.
   */
  static buildPagination(page, limit, total) {
    const currentPage = parseInt(page, 10) || 1;
    const perPage = parseInt(limit, 10) || 20;
    return {
      page: currentPage,
      limit: perPage,
      total,
      totalPages: Math.ceil(total / perPage),
      hasNext: currentPage < Math.ceil(total / perPage),
      hasPrev: currentPage > 1,
    };
  }
}

module.exports = { ApiResponse };
