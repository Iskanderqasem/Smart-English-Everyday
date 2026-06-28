const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Progress extends Model {}

Progress.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'Users', key: 'id' },
    },
    lessonId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'Lessons', key: 'id' },
    },
    exerciseId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'Exercises', key: 'id' },
    },
    status: {
      type: DataTypes.ENUM('not_started', 'in_progress', 'completed', 'failed', 'skipped'),
      defaultValue: 'not_started',
    },
    score: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    maxScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    percentage: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    xpEarned: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    timeSpentSeconds: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    attempts: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    lastAttemptAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    answers: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: 'User submitted answers with feedback',
    },
    feedback: {
      type: DataTypes.JSONB,
      defaultValue: {},
      comment: 'AI-generated feedback',
    },
    skillScores: {
      type: DataTypes.JSONB,
      defaultValue: {
        grammar: null,
        vocabulary: null,
        fluency: null,
        pronunciation: null,
        coherence: null,
      },
    },
  },
  {
    sequelize,
    modelName: 'Progress',
    tableName: 'Progress',
    indexes: [
      { fields: ['userId'] },
      { fields: ['lessonId'] },
      { fields: ['exerciseId'] },
      { unique: true, fields: ['userId', 'lessonId', 'exerciseId'] },
      { fields: ['status'] },
      { fields: ['completedAt'] },
    ],
  }
);

module.exports = Progress;
