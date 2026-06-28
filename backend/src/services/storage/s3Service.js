const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const sharp = require('sharp');
const logger = require('../../config/logger');

const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'us-east-1',
});

const BUCKET = process.env.AWS_S3_BUCKET || 'smart-english-everyday';

/**
 * Upload a file buffer to S3.
 */
const uploadFile = async (buffer, originalName, folder = 'uploads', contentType = null) => {
  const ext = path.extname(originalName).toLowerCase();
  const key = `${folder}/${uuidv4()}${ext}`;

  const params = {
    Bucket: BUCKET,
    Key: key,
    Body: buffer,
    ContentType: contentType || getMimeType(ext),
  };

  const result = await s3.upload(params).promise();
  logger.info(`File uploaded to S3: ${result.Key}`);

  return {
    key: result.Key,
    url: result.Location,
    bucket: BUCKET,
  };
};

/**
 * Delete a file from S3.
 */
const deleteFile = async (key) => {
  const params = { Bucket: BUCKET, Key: key };
  await s3.deleteObject(params).promise();
  logger.info(`File deleted from S3: ${key}`);
};

/**
 * Generate a signed URL for private S3 objects.
 */
const getSignedUrl = async (key, expiresSeconds = 3600) => {
  const params = {
    Bucket: BUCKET,
    Key: key,
    Expires: expiresSeconds,
  };
  return s3.getSignedUrlPromise('getObject', params);
};

/**
 * Upload audio file to S3.
 */
const uploadAudio = async (buffer, originalName) => {
  return uploadFile(buffer, originalName, 'audio');
};

/**
 * Upload and optimize an image using Sharp, then upload to S3.
 */
const uploadImage = async (buffer, originalName, options = {}) => {
  const { width = 800, quality = 85, format = 'webp' } = options;

  let processedBuffer;
  try {
    processedBuffer = await sharp(buffer)
      .resize(width, null, { withoutEnlargement: true })
      .toFormat(format, { quality })
      .toBuffer();
  } catch (sharpError) {
    logger.warn('Sharp processing failed, uploading original:', sharpError.message);
    processedBuffer = buffer;
  }

  const key = `images/${uuidv4()}.${format}`;
  const params = {
    Bucket: BUCKET,
    Key: key,
    Body: processedBuffer,
    ContentType: `image/${format}`,
  };

  const result = await s3.upload(params).promise();
  return {
    key: result.Key,
    url: result.Location,
    bucket: BUCKET,
  };
};

/**
 * Upload avatar with thumbnail generation.
 */
const uploadAvatar = async (buffer) => {
  const processedBuffer = await sharp(buffer)
    .resize(256, 256, { fit: 'cover' })
    .toFormat('webp', { quality: 90 })
    .toBuffer();

  const key = `avatars/${uuidv4()}.webp`;
  const params = {
    Bucket: BUCKET,
    Key: key,
    Body: processedBuffer,
    ContentType: 'image/webp',
  };

  const result = await s3.upload(params).promise();
  return {
    key: result.Key,
    url: result.Location,
  };
};

const getMimeType = (ext) => {
  const mimeMap = {
    '.mp3': 'audio/mpeg',
    '.mp4': 'audio/mp4',
    '.wav': 'audio/wav',
    '.webm': 'audio/webm',
    '.ogg': 'audio/ogg',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.webp': 'image/webp',
    '.pdf': 'application/pdf',
    '.txt': 'text/plain',
  };
  return mimeMap[ext] || 'application/octet-stream';
};

module.exports = {
  uploadFile,
  deleteFile,
  getSignedUrl,
  uploadAudio,
  uploadImage,
  uploadAvatar,
};
