const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class TestResult extends Model {}

TestResult.init(
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
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    type: {
      type: DataTypes.ENUM('quiz', 'unit_test', 'mock_exam', 'mini_test'),
      defaultValue: 'quiz',
    },
    questions: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: 'Array of questions with user answers and correct answers',
    },
    totalQuestions: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    correctAnswers: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
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
    passed: {
      type: DataTypes.BOOLEAN,
      allowNull: true,
    },
    passingScore: {
      type: DataTypes.DECIMAL(5, 2),
      defaultValue: 70.0,
    },
    timeTakenSeconds: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    xpEarned: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    feedback: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    skillBreakdown: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
    completedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
  },
  {
    sequelize,
    modelName: 'TestResult',
    tableName: 'TestResults',
    indexes: [
      { fields: ['userId'] },
      { fields: ['lessonId'] },
      { fields: ['type'] },
      { fields: ['completedAt'] },
    ],
  }
);

module.exports = TestResult;
