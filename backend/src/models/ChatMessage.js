const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class ChatMessage extends Model {}

ChatMessage.init(
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
    sessionId: {
      type: DataTypes.UUID,
      allowNull: false,
      comment: 'Groups messages into conversations',
    },
    role: {
      type: DataTypes.ENUM('user', 'assistant', 'system'),
      allowNull: false,
    },
    content: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    context: {
      type: DataTypes.ENUM('ai_teacher', 'chatbot', 'writing_feedback', 'grammar_help'),
      defaultValue: 'chatbot',
    },
    tokens: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },
    corrections: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: 'Grammar/vocabulary corrections if applicable',
    },
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
    },
  },
  {
    sequelize,
    modelName: 'ChatMessage',
    tableName: 'ChatMessages',
    indexes: [
      { fields: ['userId'] },
      { fields: ['sessionId'] },
      { fields: ['context'] },
      { fields: ['createdAt'] },
    ],
  }
);

module.exports = ChatMessage;
