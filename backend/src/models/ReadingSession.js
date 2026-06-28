const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class ReadingSession extends Model {}

ReadingSession.init(
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
    passageText: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    passageTitle: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    audioUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: 'Recorded user reading audio',
    },
    transcript: {
      type: DataTypes.TEXT,
      allowNull: true,
      comment: 'STT transcript of user reading',
    },
    pronunciationScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    accuracyScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    fluencyScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    completenessScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    overallScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    wordErrors: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: 'List of mispronounced or skipped words with corrections',
    },
    feedback: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    durationSeconds: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    wpm: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: 'Words per minute',
    },
    status: {
      type: DataTypes.ENUM('pending', 'processing', 'completed', 'failed'),
      defaultValue: 'pending',
    },
    xpEarned: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
  },
  {
    sequelize,
    modelName: 'ReadingSession',
    tableName: 'ReadingSessions',
    indexes: [
      { fields: ['userId'] },
      { fields: ['lessonId'] },
      { fields: ['status'] },
      { fields: ['createdAt'] },
    ],
  }
);

module.exports = ReadingSession;
