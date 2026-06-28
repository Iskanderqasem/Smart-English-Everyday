const http = require('http');
const { Server } = require('socket.io');
const app = require('./app');
const { sequelize } = require('./models');
const { redisClient } = require('./config/redis');
const logger = require('./config/logger');
require('./jobs/dailyWordJob');
require('./jobs/streakReminderJob');

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'], credentials: true },
});

io.on('connection', (socket) => {
  logger.info(`Socket connected: ${socket.id}`);

  socket.on('join-room', (userId) => {
    socket.join(`user:${userId}`);
    logger.info(`User ${userId} joined their room`);
  });

  socket.on('ai-message', async (data) => {
    const { userId, message, sessionId } = data;
    socket.emit('ai-typing', { sessionId });
    // AI response handled via REST API
  });

  socket.on('disconnect', () => {
    logger.info(`Socket disconnected: ${socket.id}`);
  });
});

global.io = io;

const start = async () => {
  try {
    await sequelize.authenticate();
    logger.info('Database connection established');

    if (process.env.NODE_ENV !== 'production') {
      await sequelize.sync({ alter: false });
    }

    await redisClient.ping();
    logger.info('Redis connection established');

    server.listen(PORT, () => {
      logger.info(`🚀 Smart English Everyday API running on port ${PORT}`);
      logger.info(`📚 API Docs: http://localhost:${PORT}/api/docs`);
      logger.info(`🏥 Health: http://localhost:${PORT}/health`);
    });
  } catch (err) {
    logger.error('Failed to start server:', err);
    process.exit(1);
  }
};

process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    sequelize.close();
    redisClient.quit();
    process.exit(0);
  });
});

start();
