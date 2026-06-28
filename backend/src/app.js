require('express-async-errors');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./config/swagger');
const { errorHandler } = require('./middleware/errorHandler');
const { generalLimiter } = require('./middleware/rateLimiter');
const logger = require('./config/logger');

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Request parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(compression());

// Logging
app.use(morgan('combined', { stream: { write: (msg) => logger.info(msg.trim()) } }));

// Rate limiting
app.use('/api/', generalLimiter);

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString(), version: process.env.npm_package_version || '1.0.0' }));

// API Documentation
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, { customSiteTitle: 'Smart English Everyday API' }));

// Routes
app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/users', require('./routes/user.routes'));
app.use('/api/assessment', require('./routes/assessment.routes'));
app.use('/api/levels', require('./routes/level.routes'));
app.use('/api/lessons', require('./routes/lesson.routes'));
app.use('/api/reading', require('./routes/reading.routes'));
app.use('/api/writing', require('./routes/writing.routes'));
app.use('/api/speaking', require('./routes/speaking.routes'));
app.use('/api/listening', require('./routes/listening.routes'));
app.use('/api/grammar', require('./routes/grammar.routes'));
app.use('/api/vocabulary', require('./routes/vocabulary.routes'));
app.use('/api/games', require('./routes/games.routes'));
app.use('/api/tests', require('./routes/tests.routes'));
app.use('/api/progress', require('./routes/progress.routes'));
app.use('/api/ai-teacher', require('./routes/ai-teacher.routes'));
app.use('/api/chatbot', require('./routes/chatbot.routes'));
app.use('/api/daily-words', require('./routes/daily-words.routes'));
app.use('/api/notifications', require('./routes/notifications.routes'));
app.use('/api/admin', require('./routes/admin.routes'));
app.use('/api/parent', require('./routes/parent.routes'));

// 404
app.use((req, res) => res.status(404).json({ success: false, message: `Route ${req.method} ${req.path} not found` }));

// Global error handler
app.use(errorHandler);

module.exports = app;
