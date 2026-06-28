const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Level extends Model {}

Level.init(
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    levelNumber: {
      type: DataTypes.INTEGER,
      allowNull: false,
      unique: true,
      validate: { min: 1, max: 10 },
    },
    name: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    cefrEquivalent: {
      type: DataTypes.ENUM('A1', 'A2', 'B1', 'B2', 'C1', 'C2'),
      allowNull: false,
    },
    xpRequired: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 0,
    },
    xpReward: {
      type: DataTypes.INTEGER,
      defaultValue: 100,
    },
    badgeIcon: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    color: {
      type: DataTypes.STRING(20),
      defaultValue: '#3B82F6',
    },
    skills: {
      type: DataTypes.JSONB,
      defaultValue: {
        grammar: [],
        vocabulary: [],
        speaking: [],
        writing: [],
        listening: [],
        reading: [],
      },
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
    modelName: 'Level',
    tableName: 'Levels',
    indexes: [{ unique: true, fields: ['levelNumber'] }],
  }
);

module.exports = Level;
