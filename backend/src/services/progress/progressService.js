const { Op } = require('sequelize');
const dayjs = require('dayjs');
const { User, Progress, Achievement, UserAchievement, Lesson, TestResult } = require('../../models');
const { sendAchievementNotification } = require('../notification/notificationService');
const { sendAchievementEmail } = require('../email/emailService');
const logger = require('../../config/logger');

/**
 * Update lesson/exercise progress for a user.
 */
const updateProgress = async (userId, { lessonId, exerciseId, status, score, maxScore, timeSpentSeconds, answers, feedback, skillScores }) => {
  const where = { userId };
  if (lessonId) where.lessonId = lessonId;
  if (exerciseId) where.exerciseId = exerciseId;

  const [progress, created] = await Progress.findOrCreate({
    where,
    defaults: {
      userId,
      lessonId,
      exerciseId,
      status: 'not_started',
      attempts: 0,
    },
  });

  const percentage = maxScore && maxScore > 0 ? (score / maxScore) * 100 : null;
  const xpEarned = calculateXP(score, maxScore, progress.attempts);

  await progress.update({
    status,
    score,
    maxScore,
    percentage,
    xpEarned: (progress.xpEarned || 0) + xpEarned,
    timeSpentSeconds: (progress.timeSpentSeconds || 0) + (timeSpentSeconds || 0),
    attempts: progress.attempts + 1,
    lastAttemptAt: new Date(),
    completedAt: status === 'completed' ? new Date() : progress.completedAt,
    answers: answers || progress.answers,
    feedback: feedback || progress.feedback,
    skillScores: skillScores || progress.skillScores,
  });

  // Update user total XP
  if (xpEarned > 0) {
    await User.increment({ totalXP: xpEarned }, { where: { id: userId } });
  }

  return { progress, xpEarned, isNew: created };
};

/**
 * Calculate XP earned for a submission.
 */
const calculateXP = (score, maxScore, attempts) => {
  if (!score || !maxScore) return 0;
  const percentage = (score / maxScore) * 100;
  const baseXP = percentage >= 90 ? 50 : percentage >= 75 ? 35 : percentage >= 60 ? 20 : 10;
  const attemptPenalty = Math.max(0, (attempts - 1) * 5);
  return Math.max(5, baseXP - attemptPenalty);
};

/**
 * Calculate and update user streak.
 */
const calculateStreak = async (userId) => {
  const user = await User.findByPk(userId);
  if (!user) return null;

  const today = dayjs().startOf('day');
  const lastLogin = user.lastLoginAt ? dayjs(user.lastLoginAt).startOf('day') : null;

  let newStreak = user.currentStreak;

  if (!lastLogin) {
    newStreak = 1;
  } else if (lastLogin.isSame(today)) {
    // Already counted today
    return { currentStreak: user.currentStreak, longestStreak: user.longestStreak };
  } else if (lastLogin.isSame(today.subtract(1, 'day'))) {
    // Consecutive day
    newStreak = user.currentStreak + 1;
  } else {
    // Streak broken
    newStreak = 1;
  }

  const longestStreak = Math.max(newStreak, user.longestStreak);

  await user.update({
    currentStreak: newStreak,
    longestStreak,
    lastLoginAt: new Date(),
  });

  return { currentStreak: newStreak, longestStreak, streakIncreased: newStreak > user.currentStreak };
};

/**
 * Check and award achievements to a user.
 */
const awardAchievement = async (userId, achievementId) => {
  const existing = await UserAchievement.findOne({
    where: { userId, achievementId },
  });

  if (existing) return null; // Already awarded

  const achievement = await Achievement.findByPk(achievementId);
  if (!achievement || !achievement.isActive) return null;

  const userAchievement = await UserAchievement.create({
    userId,
    achievementId,
    xpAwarded: achievement.xpReward,
    earnedAt: new Date(),
  });

  // Award XP
  if (achievement.xpReward > 0) {
    await User.increment({ totalXP: achievement.xpReward }, { where: { id: userId } });
  }

  // Send notifications
  const user = await User.findByPk(userId);
  if (user) {
    try {
      await sendAchievementNotification(user, achievement);
      if (user.preferences?.notifications?.email) {
        await sendAchievementEmail(user, achievement);
      }
    } catch (notifError) {
      logger.warn('Failed to send achievement notification:', notifError);
    }
  }

  return userAchievement;
};

/**
 * Check achievement conditions and award any that are met.
 */
const checkAndAwardAchievements = async (userId) => {
  const user = await User.findByPk(userId, {
    include: [{ model: UserAchievement, as: 'userAchievements', attributes: ['achievementId'] }],
  });

  if (!user) return [];

  const earnedIds = user.userAchievements.map((ua) => ua.achievementId);
  const availableAchievements = await Achievement.findAll({
    where: { isActive: true, id: { [Op.notIn]: earnedIds } },
  });

  const newAchievements = [];

  for (const achievement of availableAchievements) {
    const condition = achievement.condition;
    let met = false;

    switch (condition.type) {
      case 'streak':
        met = user.currentStreak >= condition.value;
        break;
      case 'total_xp':
        met = user.totalXP >= condition.value;
        break;
      case 'lessons_completed': {
        const count = await Progress.count({
          where: { userId, status: 'completed', lessonId: { [Op.ne]: null } },
        });
        met = count >= condition.value;
        break;
      }
      case 'test_score': {
        const highScore = await TestResult.findOne({
          where: { userId, percentage: { [Op.gte]: condition.value } },
        });
        met = !!highScore;
        break;
      }
      default:
        break;
    }

    if (met) {
      const awarded = await awardAchievement(userId, achievement.id);
      if (awarded) newAchievements.push(achievement);
    }
  }

  return newAchievements;
};

/**
 * Get a comprehensive progress summary for a user.
 */
const getProgressSummary = async (userId) => {
  const [
    user,
    completedLessons,
    totalTimeSpent,
    recentProgress,
    achievements,
  ] = await Promise.all([
    User.findByPk(userId, { attributes: ['id', 'cefrLevel', 'currentStreak', 'longestStreak', 'totalXP'] }),
    Progress.count({ where: { userId, status: 'completed', lessonId: { [Op.ne]: null } } }),
    Progress.sum('timeSpentSeconds', { where: { userId } }),
    Progress.findAll({
      where: { userId, status: 'completed' },
      order: [['completedAt', 'DESC']],
      limit: 10,
      include: [{ model: Lesson, as: 'lesson', attributes: ['title', 'type'] }],
    }),
    UserAchievement.count({ where: { userId } }),
  ]);

  return {
    cefrLevel: user?.cefrLevel,
    currentStreak: user?.currentStreak || 0,
    longestStreak: user?.longestStreak || 0,
    totalXP: user?.totalXP || 0,
    completedLessons,
    totalStudyMinutes: Math.round((totalTimeSpent || 0) / 60),
    achievementsEarned: achievements,
    recentActivity: recentProgress,
  };
};

/**
 * Generate a weekly progress report for a user.
 */
const generateWeeklyReport = async (userId) => {
  const weekAgo = dayjs().subtract(7, 'day').toDate();

  const [lessonsCompleted, xpEarned, studyTime, testResults] = await Promise.all([
    Progress.count({
      where: { userId, status: 'completed', completedAt: { [Op.gte]: weekAgo } },
    }),
    Progress.sum('xpEarned', { where: { userId, createdAt: { [Op.gte]: weekAgo } } }),
    Progress.sum('timeSpentSeconds', { where: { userId, createdAt: { [Op.gte]: weekAgo } } }),
    TestResult.findAll({
      where: { userId, completedAt: { [Op.gte]: weekAgo } },
      attributes: ['percentage', 'type'],
    }),
  ]);

  const avgTestScore =
    testResults.length > 0
      ? testResults.reduce((sum, t) => sum + parseFloat(t.percentage || 0), 0) / testResults.length
      : null;

  const user = await User.findByPk(userId, {
    attributes: ['currentStreak', 'totalXP'],
  });

  return {
    lessonsCompleted: lessonsCompleted || 0,
    xpEarned: xpEarned || 0,
    studyMinutes: Math.round((studyTime || 0) / 60),
    testsCompleted: testResults.length,
    avgTestScore: avgTestScore ? Math.round(avgTestScore) : null,
    currentStreak: user?.currentStreak || 0,
  };
};

module.exports = {
  updateProgress,
  calculateStreak,
  awardAchievement,
  checkAndAwardAchievements,
  getProgressSummary,
  generateWeeklyReport,
};
