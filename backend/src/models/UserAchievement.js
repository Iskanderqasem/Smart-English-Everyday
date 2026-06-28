const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class UserAchievement extends Model {}

UserAchievement.init(
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
    achievementId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: { model: 'Achievements', key: 'id' },
    },
    earnedAt: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    xpAwarded: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    notified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
  },
  {
    sequelize,
    modelName: 'UserAchievement',
    tableName: 'UserAchievements',
    indexes: [
      { unique: true, fields: ['userId', 'achievementId'] },
      { fields: ['userId'] },
      { fields: ['earnedAt'] },
    ],
  }
);

module.exports = UserAchievement;
