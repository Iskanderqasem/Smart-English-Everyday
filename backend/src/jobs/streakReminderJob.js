const cron = require('node-cron');
const logger = require('../config/logger');

// Weekly progress report every Sunday at 9 AM
cron.schedule('0 9 * * 0', async () => {
  try {
    logger.info('Running weekly progress report job');
    const { User } = require('../models');
    const progressService = require('../services/progress/progressService');
    const emailService = require('../services/email/emailService');

    const students = await User.findAll({ where: { role: 'student', isActive: true, isEmailVerified: true }, attributes: ['id', 'email', 'firstName'], limit: 500 });

    for (const student of students) {
      const report = await progressService.generateWeeklyReport(student.id);
      if (report.lessonsCompleted > 0) {
        await emailService.sendWeeklyProgress(student.email, student.firstName, report);
      }
    }

    logger.info(`Weekly reports sent to ${students.length} students`);
  } catch (err) {
    logger.error('Weekly report job error:', err);
  }
});

module.exports = {};
