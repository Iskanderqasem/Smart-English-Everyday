const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Lesson extends Model {}

Lesson.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    levelId: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: { model: 'Levels', key: 'id' },
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    type: {
      type: DataTypes.ENUM(
        'grammar',
        'vocabulary',
        'reading',
        'writing',
        'speaking',
        'listening',
        'mixed'
      ),
      allowNull: false,
    },
    content: {
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {},
    },
    audioUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    videoUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    imageUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    durationMinutes: {
      type: DataTypes.INTEGER,
      defaultValue: 15,
    },
    xpReward: {
      type: DataTypes.INTEGER,
      defaultValue: 50,
    },
    difficulty: {
      type: DataTypes.ENUM('easy', 'medium', 'hard'),
      defaultValue: 'medium',
    },
    tags: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: [],
    },
    prerequisites: {
      type: DataTypes.ARRAY(DataTypes.UUID),
      defaultValue: [],
    },
    isPublished: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    sortOrder: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    createdBy: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'Users', key: 'id' },
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
  },
  {
    sequelize,
    modelName: 'Lesson',
    tableName: 'Lessons',
    indexes: [
      { fields: ['levelId'] },
      { fields: ['type'] },
      { fields: ['isPublished'] },
      { fields: ['difficulty'] },
    ],
  }
);

module.exports = Lesson;
