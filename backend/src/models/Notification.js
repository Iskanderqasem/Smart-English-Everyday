const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Notification extends Model {}

Notification.init(
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
      type: DataTypes.ENUM(
        'achievement',
        'streak_reminder',
        'daily_word',
        'lesson_reminder',
        'weekly_report',
        'level_up',
        'system',
        'promotional'
      ),
      allowNull: false,
    },
    title: {
      type: DataTypes.STRING(255),
      allowNull: false,
    },
    body: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    data: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
    isRead: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    readAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    channel: {
      type: DataTypes.ENUM('in_app', 'push', 'email', 'sms'),
      defaultValue: 'in_app',
    },
    sentAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    scheduledFor: {
      type: DataTypes.DATE,
      allowNull: true,
    },
  },
  {
    sequelize,
    modelName: 'Notification',
    tableName: 'Notifications',
    indexes: [
      { fields: ['userId'] },
      { fields: ['isRead'] },
      { fields: ['type'] },
      { fields: ['sentAt'] },
      { fields: ['scheduledFor'] },
    ],
  }
);

module.exports = Notification;
