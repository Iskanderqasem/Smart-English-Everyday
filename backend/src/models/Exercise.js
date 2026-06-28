const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Exercise extends Model {}

Exercise.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    lessonId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'Lessons', key: 'id' },
    },
    type: {
      type: DataTypes.ENUM(
        'multiple_choice',
        'fill_in_blank',
        'matching',
        'ordering',
        'true_false',
        'short_answer',
        'essay',
        'speaking',
        'listening',
        'reading_comprehension',
        'drag_drop',
        'word_scramble'
      ),
      allowNull: false,
    },
    question: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    instructions: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    content: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {},
      comment: 'Exercise-specific content: options, audio, image, etc.',
    },
    correctAnswer: {
      type: DataTypes.JSONB,
      allowNull: false,
      comment: 'Correct answer(s) - varies by type',
    },
    explanation: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    hints: {
      type: DataTypes.ARRAY(DataTypes.TEXT),
      defaultValue: [],
    },
    points: {
      type: DataTypes.INTEGER,
      defaultValue: 10,
    },
    timeLimit: {
      type: DataTypes.INTEGER,
      allowNull: true,
      comment: 'Time limit in seconds, null = no limit',
    },
    difficulty: {
      type: DataTypes.ENUM('easy', 'medium', 'hard'),
      defaultValue: 'medium',
    },
    skillArea: {
      type: DataTypes.ENUM('grammar', 'vocabulary', 'reading', 'writing', 'speaking', 'listening'),
      allowNull: true,
    },
    tags: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: [],
    },
    sortOrder: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
  },
  {
    sequelize,
    modelName: 'Exercise',
    tableName: 'Exercises',
    indexes: [
      { fields: ['lessonId'] },
      { fields: ['type'] },
      { fields: ['skillArea'] },
      { fields: ['difficulty'] },
    ],
  }
);

module.exports = Exercise;
