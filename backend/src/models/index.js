const { sequelize } = require('../config/database');
const User = require('./User');
const Level = require('./Level');
const Lesson = require('./Lesson');
const Exercise = require('./Exercise');
const Progress = require('./Progress');
const Assessment = require('./Assessment');
const Word = require('./Word');
const Achievement = require('./Achievement');
const UserAchievement = require('./UserAchievement');
const Notification = require('./Notification');
const ChatMessage = require('./ChatMessage');
const ReadingSession = require('./ReadingSession');
const WritingSubmission = require('./WritingSubmission');
const SpeakingSession = require('./SpeakingSession');
const TestResult = require('./TestResult');

// ─── User self-referential (parent/child) ───────────────────────────────────
User.hasMany(User, { as: 'children', foreignKey: 'parentId' });
User.belongsTo(User, { as: 'parent', foreignKey: 'parentId' });

// ─── Level ↔ Lesson ─────────────────────────────────────────────────────────
Level.hasMany(Lesson, { foreignKey: 'levelId', as: 'lessons' });
Lesson.belongsTo(Level, { foreignKey: 'levelId', as: 'level' });

// ─── Lesson ↔ Exercise ──────────────────────────────────────────────────────
Lesson.hasMany(Exercise, { foreignKey: 'lessonId', as: 'exercises' });
Exercise.belongsTo(Lesson, { foreignKey: 'lessonId', as: 'lesson' });

// ─── User ↔ Progress ────────────────────────────────────────────────────────
User.hasMany(Progress, { foreignKey: 'userId', as: 'progress' });
Progress.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Lesson.hasMany(Progress, { foreignKey: 'lessonId', as: 'progress' });
Progress.belongsTo(Lesson, { foreignKey: 'lessonId', as: 'lesson' });
Exercise.hasMany(Progress, { foreignKey: 'exerciseId', as: 'progress' });
Progress.belongsTo(Exercise, { foreignKey: 'exerciseId', as: 'exercise' });

// ─── User ↔ Assessment ──────────────────────────────────────────────────────
User.hasMany(Assessment, { foreignKey: 'userId', as: 'assessments' });
Assessment.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// ─── User ↔ Achievement (through UserAchievement) ───────────────────────────
User.belongsToMany(Achievement, {
  through: UserAchievement,
  foreignKey: 'userId',
  otherKey: 'achievementId',
  as: 'achievements',
});
Achievement.belongsToMany(User, {
  through: UserAchievement,
  foreignKey: 'achievementId',
  otherKey: 'userId',
  as: 'users',
});
User.hasMany(UserAchievement, { foreignKey: 'userId', as: 'userAchievements' });
UserAchievement.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Achievement.hasMany(UserAchievement, { foreignKey: 'achievementId', as: 'userAchievements' });
UserAchievement.belongsTo(Achievement, { foreignKey: 'achievementId', as: 'achievement' });

// ─── User ↔ Notification ────────────────────────────────────────────────────
User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// ─── User ↔ ChatMessage ─────────────────────────────────────────────────────
User.hasMany(ChatMessage, { foreignKey: 'userId', as: 'chatMessages' });
ChatMessage.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// ─── User ↔ ReadingSession ──────────────────────────────────────────────────
User.hasMany(ReadingSession, { foreignKey: 'userId', as: 'readingSessions' });
ReadingSession.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Lesson.hasMany(ReadingSession, { foreignKey: 'lessonId', as: 'readingSessions' });
ReadingSession.belongsTo(Lesson, { foreignKey: 'lessonId', as: 'lesson' });

// ─── User ↔ WritingSubmission ────────────────────────────────────────────────
User.hasMany(WritingSubmission, { foreignKey: 'userId', as: 'writingSubmissions' });
WritingSubmission.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// ─── User ↔ SpeakingSession ─────────────────────────────────────────────────
User.hasMany(SpeakingSession, { foreignKey: 'userId', as: 'speakingSessions' });
SpeakingSession.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// ─── User ↔ TestResult ──────────────────────────────────────────────────────
User.hasMany(TestResult, { foreignKey: 'userId', as: 'testResults' });
TestResult.belongsTo(User, { foreignKey: 'userId', as: 'user' });
Lesson.hasMany(TestResult, { foreignKey: 'lessonId', as: 'testResults' });
TestResult.belongsTo(Lesson, { foreignKey: 'lessonId', as: 'lesson' });

// ─── Lesson ↔ User (creator) ────────────────────────────────────────────────
User.hasMany(Lesson, { foreignKey: 'createdBy', as: 'createdLessons' });
Lesson.belongsTo(User, { foreignKey: 'createdBy', as: 'creator' });

module.exports = {
  sequelize,
  User,
  Level,
  Lesson,
  Exercise,
  Progress,
  Assessment,
  Word,
  Achievement,
  UserAchievement,
  Notification,
  ChatMessage,
  ReadingSession,
  WritingSubmission,
  SpeakingSession,
  TestResult,
};
