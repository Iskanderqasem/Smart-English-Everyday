const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const { ApiResponse } = require('../utils/apiResponse');

// Use memory storage to pipe to S3
const storage = multer.memoryStorage();

const fileFilter = (allowedTypes) => (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase().slice(1);
  const mime = file.mimetype;

  const allowed = allowedTypes.some((type) => {
    if (type.includes('/')) return mime === type;
    return ext === type;
  });

  if (allowed) {
    cb(null, true);
  } else {
    cb(
      new Error(`Invalid file type. Allowed: ${allowedTypes.join(', ')}. Got: ${mime}`),
      false
    );
  }
};

// Audio upload (speaking/reading)
const audioUpload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_AUDIO_SIZE_MB || '50', 10) * 1024 * 1024,
    files: 1,
  },
  fileFilter: fileFilter([
    'audio/mpeg',
    'audio/mp4',
    'audio/wav',
    'audio/webm',
    'audio/ogg',
    'audio/flac',
    'audio/x-wav',
    'audio/x-m4a',
  ]),
});

// Image upload (avatar, lesson images)
const imageUpload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_IMAGE_SIZE_MB || '10', 10) * 1024 * 1024,
    files: 1,
  },
  fileFilter: fileFilter(['image/jpeg', 'image/png', 'image/gif', 'image/webp']),
});

// Document upload (writing submissions as files)
const documentUpload = multer({
  storage,
  limits: {
    fileSize: parseInt(process.env.MAX_DOC_SIZE_MB || '20', 10) * 1024 * 1024,
    files: 1,
  },
  fileFilter: fileFilter([
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
  ]),
});

// Error handler for multer errors
const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return ApiResponse.badRequest(res, 'File size exceeds the allowed limit.');
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return ApiResponse.badRequest(res, 'Too many files uploaded.');
    }
    return ApiResponse.badRequest(res, `Upload error: ${err.message}`);
  }
  if (err) {
    return ApiResponse.badRequest(res, err.message);
  }
  return next();
};

module.exports = {
  audioUpload,
  imageUpload,
  documentUpload,
  handleUploadError,
};
