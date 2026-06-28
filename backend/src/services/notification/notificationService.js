const { Notification, User } = require('../../models');
const logger = require('../../config/logger');

/**
 * Create an in-app notification.
 */
const createNotification = async (userId, { type, title, body, data = {}, channel = 'in_app', scheduledFor = null }) => {
  try {
    const notification = await Notification.create({
      userId,
      type,
      title,
      body,
      data,
      channel,
      scheduledFor,
      sentAt: scheduledFor ? null : new Date(),
    });
    return notification;
  } catch (error) {
    logger.error('Failed to create notification:', error);
    throw error;
  }
};

/**
 * Send a push notification via FCM.
 */
const sendPushNotification = async (user, { title, body, data = {} }) => {
  if (!user.fcmToken) {
    logger.debug(`No FCM token for user ${user.id}, skipping push notification.`);
    return null;
  }

  // FCM HTTP v1 API
  try {
    const message = {
      token: user.fcmToken,
      notification: { title, body },
      data: Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])),
      android: {
        notification: {
          icon: 'notification_icon',
          color: '#6366f1',
          sound: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            alert: { title, body },
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    // If Firebase Admin SDK is configured
    if (process.env.FIREBASE_PROJECT_ID) {
      const admin = require('firebase-admin');
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
          }),
        });
      }
      const response = await admin.messaging().send(message);
      logger.info(`Push notification sent to ${user.id}: ${response}`);
      return response;
    }

    logger.debug(`Firebase not configured. Would have sent push to user ${user.id}: ${title}`);
    return null;
  } catch (error) {
    logger.error(`Failed to send push notification to user ${user.id}:`, error);
    // Non-fatal - don't throw
    return null;
  }
};

/**
 * Send a daily word notification to a user.
 */
const sendDailyWordNotification = async (user, word) => {
  const notification = await createNotification(user.id, {
    type: 'daily_word',
    title: `📚 Word of the Day: ${word.word}`,
    body: `${word.partOfSpeech} - ${word.definition.slice(0, 100)}...`,
    data: { wordId: word.id, word: word.word },
    channel: 'in_app',
  });

  if (user.preferences?.notifications?.push && user.preferences?.notifications?.dailyWord) {
    await sendPushNotification(user, {
      title: `📚 Word of the Day: ${word.word}`,
      body: `${word.partOfSpeech} - ${word.definition.slice(0, 100)}`,
      data: { type: 'daily_word', wordId: word.id },
    });
  }

  return notification;
};

/**
 * Send streak reminder notification.
 */
const sendStreakReminder = async (user) => {
  const notification = await createNotification(user.id, {
    type: 'streak_reminder',
    title: `🔥 Keep your ${user.currentStreak}-day streak alive!`,
    body: "You haven't studied today. Don't break your streak - practice for just 5 minutes!",
    channel: 'in_app',
  });

  if (user.preferences?.notifications?.push && user.preferences?.notifications?.streakReminder) {
    await sendPushNotification(user, {
      title: `🔥 Keep your ${user.currentStreak}-day streak alive!`,
      body: "Don't break your streak! Practice for just 5 minutes.",
      data: { type: 'streak_reminder' },
    });
  }

  return notification;
};

/**
 * Send achievement notification.
 */
const sendAchievementNotification = async (user, achievement) => {
  const notification = await createNotification(user.id, {
    type: 'achievement',
    title: `🏆 Achievement Unlocked: ${achievement.name}!`,
    body: achievement.description,
    data: { achievementId: achievement.id, xpReward: achievement.xpReward },
    channel: 'in_app',
  });

  if (user.preferences?.notifications?.push) {
    await sendPushNotification(user, {
      title: `🏆 Achievement: ${achievement.name}!`,
      body: `${achievement.description} +${achievement.xpReward} XP`,
      data: { type: 'achievement', achievementId: achievement.id },
    });
  }

  return notification;
};

/**
 * Broadcast a notification to all users or a filtered subset.
 */
const broadcastNotification = async ({ type, title, body, data = {}, filter = {} }) => {
  const whereClause = { isActive: true, ...filter };
  const users = await User.findAll({
    where: whereClause,
    attributes: ['id', 'fcmToken', 'preferences'],
  });

  const results = await Promise.allSettled(
    users.map((user) =>
      createNotification(user.id, { type, title, body, data, channel: 'in_app' })
    )
  );

  const created = results.filter((r) => r.status === 'fulfilled').length;
  const failed = results.filter((r) => r.status === 'rejected').length;

  logger.info(`Broadcast notification sent: ${created} created, ${failed} failed`);
  return { total: users.length, created, failed };
};

/**
 * Mark notification(s) as read.
 */
const markAsRead = async (notificationId, userId) => {
  const [updated] = await Notification.update(
    { isRead: true, readAt: new Date() },
    { where: { id: notificationId, userId } }
  );
  return updated > 0;
};

/**
 * Get unread notification count for a user.
 */
const getUnreadCount = async (userId) => {
  return Notification.count({ where: { userId, isRead: false } });
};

module.exports = {
  createNotification,
  sendPushNotification,
  sendDailyWordNotification,
  sendStreakReminder,
  sendAchievementNotification,
  broadcastNotification,
  markAsRead,
  getUnreadCount,
};
