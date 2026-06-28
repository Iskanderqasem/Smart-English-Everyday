const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class SpeakingSession extends Model {}

SpeakingSession.init(
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
    topic: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    taskType: {
      type: DataTypes.ENUM('describe_image', 'discuss_topic', 'roleplay', 'retell_story', 'free'),
      defaultValue: 'discuss_topic',
    },
    prompt: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    audioUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    transcript: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    pronunciationScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    fluencyScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    grammarScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    vocabularyScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    coherenceScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    overallScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    cefrLevel: {
      type: DataTypes.ENUM('A1', 'A2', 'B1', 'B2', 'C1', 'C2'),
      allowNull: true,
    },
    feedback: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    corrections: {
      type: DataTypes.JSONB,
      defaultValue: [],
    },
    phonemeErrors: {
      type: DataTypes.JSONB,
      defaultValue: [],
    },
    durationSeconds: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    wordCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
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
    modelName: 'SpeakingSession',
    tableName: 'SpeakingSessions',
    indexes: [
      { fields: ['userId'] },
      { fields: ['taskType'] },
      { fields: ['status'] },
      { fields: ['createdAt'] },
    ],
  }
);

module.exports = SpeakingSession;
