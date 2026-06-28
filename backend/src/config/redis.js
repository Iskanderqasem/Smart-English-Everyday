const Redis = require('ioredis');
const logger = require('./logger');

let redisClient = null;

const createRedisClient = () => {
  const config = {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT, 10) || 6379,
    password: process.env.REDIS_PASSWORD || undefined,
    db: parseInt(process.env.REDIS_DB, 10) || 0,
    retryStrategy: (times) => {
      const delay = Math.min(times * 50, 2000);
      return delay;
    },
    maxRetriesPerRequest: 3,
    enableReadyCheck: true,
    lazyConnect: false,
  };

  if (process.env.REDIS_URL) {
    redisClient = new Redis(process.env.REDIS_URL, {
      retryStrategy: config.retryStrategy,
      maxRetriesPerRequest: config.maxRetriesPerRequest,
    });
  } else {
    redisClient = new Redis(config);
  }

  redisClient.on('connect', () => {
    logger.info('Redis client connected.');
  });

  redisClient.on('ready', () => {
    logger.info('Redis client ready.');
  });

  redisClient.on('error', (err) => {
    logger.error('Redis client error:', err);
  });

  redisClient.on('close', () => {
    logger.warn('Redis client connection closed.');
  });

  redisClient.on('reconnecting', () => {
    logger.info('Redis client reconnecting...');
  });

  return redisClient;
};

const getRedisClient = () => {
  if (!redisClient) {
    return createRedisClient();
  }
  return redisClient;
};

const connectRedis = async () => {
  try {
    const client = getRedisClient();
    await client.ping();
    logger.info('Redis connection verified with PING.');
    return client;
  } catch (error) {
    logger.error('Redis connection failed:', error);
    throw error;
  }
};

const disconnectRedis = async () => {
  if (redisClient) {
    await redisClient.quit();
    redisClient = null;
    logger.info('Redis client disconnected.');
  }
};

// Cache helpers
const setCache = async (key, value, ttlSeconds = 3600) => {
  const client = getRedisClient();
  await client.setex(key, ttlSeconds, JSON.stringify(value));
};

const getCache = async (key) => {
  const client = getRedisClient();
  const data = await client.get(key);
  return data ? JSON.parse(data) : null;
};

const deleteCache = async (key) => {
  const client = getRedisClient();
  await client.del(key);
};

const deleteCachePattern = async (pattern) => {
  const client = getRedisClient();
  const keys = await client.keys(pattern);
  if (keys.length > 0) {
    await client.del(...keys);
  }
};

module.exports = {
  getRedisClient,
  connectRedis,
  disconnectRedis,
  setCache,
  getCache,
  deleteCache,
  deleteCachePattern,
};
