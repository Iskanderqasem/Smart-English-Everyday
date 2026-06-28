const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Assessment extends Model {}

Assessment.init(
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
    type: {
      type: DataTypes.ENUM('placement', 'progress', 'final', 'ielts_mock', 'toefl_mock'),
      defaultValue: 'placement',
    },
    status: {
      type: DataTypes.ENUM('pending', 'in_progress', 'completed', 'expired'),
      defaultValue: 'pending',
    },
    sections: {
      type: DataTypes.JSONB,
      defaultValue: {
        reading: { completed: false, score: null, maxScore: null },
        listening: { completed: false, score: null, maxScore: null },
        writing: { completed: false, score: null, maxScore: null },
        speaking: { completed: false, score: null, maxScore: null },
        grammar: { completed: false, score: null, maxScore: null },
        vocabulary: { completed: false, score: null, maxScore: null },
      },
    },
    overallScore: {
      type: DataTypes.DECIMAL(5, 2),
      allowNull: true,
    },
    cefrLevel: {
      type: DataTypes.ENUM('A1', 'A2', 'B1', 'B2', 'C1', 'C2'),
      allowNull: true,
    },
    ieltsEstimate: {
      type: DataTypes.DECIMAL(3, 1),
      allowNull: true,
    },
    toeflEstimate: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    feedback: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
    recommendations: {
      type: DataTypes.JSONB,
      defaultValue: [],
    },
    startedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    completedAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
  },
  {
    sequelize,
    modelName: 'Assessment',
    tableName: 'Assessments',
    indexes: [
      { fields: ['userId'] },
      { fields: ['type'] },
      { fields: ['status'] },
      { fields: ['completedAt'] },
    ],
  }
);

module.exports = Assessment;
