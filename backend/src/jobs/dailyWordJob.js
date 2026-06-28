const cron = require('node-cron');
const { Word, User } = require('../models');
const notificationService = require('../services/notification/notificationService');
const { redisClient } = require('../config/redis');
const logger = require('../config/logger');

// Run every day at 8:00 AM UTC
cron.schedule('0 8 * * *', async () => {
  try {
    logger.info('Running daily word notification job');

    const word = await Word.findOne({ order: require('sequelize').literal('random()') });
    if (!word) return;

    const today = new Date().toISOString().split('T')[0];
    await redisClient.setEx(`daily-word:${today}`, 86400, JSON.stringify(word));

    const students = await User.findAll({ where: { role: 'student', isActive: true, fcmToken: { [require('sequelize').Op.ne]: null } }, attributes: ['id', 'fcmToken', 'firstName'] });

    for (const student of students) {
      await notificationService.sendPushNotification(student.fcmToken, {
        title: `📚 Word of the Day: ${word.word}`,
        body: `${word.pronunciation} — ${word.definition.substring(0, 80)}...`,
        data: { type: 'daily_word', wordId: word.id },
      });
    }

    logger.info(`Daily word notifications sent to ${students.length} students`);
  } catch (err) {
    logger.error('Daily word job error:', err);
  }
});

// Run at 7 PM for evening reminder
cron.schedule('0 19 * * *', async () => {
  try {
    logger.info('Running evening streak reminder job');
    const { Op } = require('sequelize');

    const studentsWhoHaventStudied = await User.findAll({
      where: {
        role: 'student',
        isActive: true,
        fcmToken: { [Op.ne]: null },
        lastLoginAt: { [Op.lt]: new Date(new Date().setHours(0, 0, 0, 0)) },
      },
      attributes: ['id', 'fcmToken', 'firstName'],
      limit: 1000,
    });

    for (const student of studentsWhoHaventStudied) {
      await notificationService.sendPushNotification(student.fcmToken, {
        title: `🔥 Don\'t break your streak, ${student.firstName}!`,
        body: 'You haven\'t studied today. Just 5 minutes keeps your streak alive!',
        data: { type: 'streak_reminder' },
      });
    }
  } catch (err) {
    logger.error('Streak reminder job error:', err);
  }
});

module.exports = {};
