const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Achievement extends Model {}

Achievement.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
      unique: true,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    category: {
      type: DataTypes.ENUM(
        'streak',
        'lessons',
        'exercises',
        'vocabulary',
        'speaking',
        'writing',
        'reading',
        'listening',
        'grammar',
        'assessment',
        'social',
        'special'
      ),
      allowNull: false,
    },
    badgeIcon: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    badgeColor: {
      type: DataTypes.STRING(20),
      defaultValue: '#FFD700',
    },
    xpReward: {
      type: DataTypes.INTEGER,
      defaultValue: 100,
    },
    condition: {
      type: DataTypes.JSONB,
      allowNull: false,
      comment: 'Condition to earn achievement: { type, value, metric }',
    },
    rarity: {
      type: DataTypes.ENUM('common', 'uncommon', 'rare', 'epic', 'legendary'),
      defaultValue: 'common',
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    sortOrder: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
  },
  {
    sequelize,
    modelName: 'Achievement',
    tableName: 'Achievements',
    indexes: [
      { fields: ['category'] },
      { fields: ['rarity'] },
      { fields: ['isActive'] },
    ],
  }
);

module.exports = Achievement;
