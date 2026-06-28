const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class WritingSubmission extends Model {}

WritingSubmission.init(
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
      type: DataTypes.ENUM('essay', 'letter', 'email', 'report', 'story', 'summary', 'free'),
      defaultValue: 'essay',
    },
    prompt: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    submittedText: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    wordCount: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
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
    structureScore: {
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
    correctedText: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    corrections: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: 'Array of { original, corrected, explanation, type } objects',
    },
    generalFeedback: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    strengths: {
      type: DataTypes.ARRAY(DataTypes.TEXT),
      defaultValue: [],
    },
    improvements: {
      type: DataTypes.ARRAY(DataTypes.TEXT),
      defaultValue: [],
    },
    status: {
      type: DataTypes.ENUM('pending', 'analyzed', 'failed'),
      defaultValue: 'pending',
    },
    xpEarned: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
  },
  {
    sequelize,
    modelName: 'WritingSubmission',
    tableName: 'WritingSubmissions',
    indexes: [
      { fields: ['userId'] },
      { fields: ['taskType'] },
      { fields: ['status'] },
      { fields: ['createdAt'] },
    ],
  }
);

module.exports = WritingSubmission;
