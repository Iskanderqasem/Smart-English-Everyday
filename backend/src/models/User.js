const { DataTypes, Model } = require('sequelize');
const bcrypt = require('bcryptjs');
const { sequelize } = require('../config/database');

class User extends Model {
  async comparePassword(candidatePassword) {
    return bcrypt.compare(candidatePassword, this.password);
  }

  toJSON() {
    const values = { ...this.get() };
    delete values.password;
    delete values.twoFactorSecret;
    delete values.passwordResetToken;
    delete values.emailVerificationToken;
    return values;
  }
}

User.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    username: {
      type: DataTypes.STRING(50),
      allowNull: false,
      unique: true,
      validate: {
        len: [3, 50],
        is: /^[a-zA-Z0-9_.-]+$/,
      },
    },
    email: {
      type: DataTypes.STRING(255),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: {
      type: DataTypes.STRING(255),
      allowNull: true, // null for social auth
    },
    firstName: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    lastName: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    avatar: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    englishVariant: {
      type: DataTypes.ENUM('UK', 'US', 'AU', 'NZ', 'CA'),
      defaultValue: 'US',
    },
    role: {
      type: DataTypes.ENUM('student', 'teacher', 'parent', 'admin'),
      defaultValue: 'student',
    },
    cefrLevel: {
      type: DataTypes.ENUM('A1', 'A2', 'B1', 'B2', 'C1', 'C2'),
      allowNull: true,
    },
    ieltsEstimate: {
      type: DataTypes.DECIMAL(3, 1),
      allowNull: true,
      validate: { min: 0, max: 9 },
    },
    toeflEstimate: {
      type: DataTypes.INTEGER,
      allowNull: true,
      validate: { min: 0, max: 120 },
    },
    isEmailVerified: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    emailVerificationToken: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    emailVerificationExpires: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    twoFactorEnabled: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    twoFactorSecret: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    googleId: {
      type: DataTypes.STRING(255),
      allowNull: true,
      unique: true,
    },
    facebookId: {
      type: DataTypes.STRING(255),
      allowNull: true,
      unique: true,
    },
    appleId: {
      type: DataTypes.STRING(255),
      allowNull: true,
      unique: true,
    },
    passwordResetToken: {
      type: DataTypes.STRING(255),
      allowNull: true,
    },
    passwordResetExpires: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    lastLoginAt: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    currentStreak: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    longestStreak: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    totalXP: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    preferences: {
      type: DataTypes.JSONB,
      defaultValue: {
        notifications: {
          email: true,
          push: true,
          dailyWord: true,
          streakReminder: true,
          weeklyReport: true,
        },
        learningGoals: {
          dailyMinutes: 20,
          weeklyLessons: 5,
        },
        theme: 'light',
        language: 'en',
      },
    },
    fcmToken: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    timezone: {
      type: DataTypes.STRING(50),
      defaultValue: 'UTC',
    },
    parentId: {
      type: DataTypes.UUID,
      allowNull: true,
      references: { model: 'Users', key: 'id' },
    },
  },
  {
    sequelize,
    modelName: 'User',
    tableName: 'Users',
    hooks: {
      beforeCreate: async (user) => {
        if (user.password) {
          user.password = await bcrypt.hash(user.password, 12);
        }
      },
      beforeUpdate: async (user) => {
        if (user.changed('password') && user.password) {
          user.password = await bcrypt.hash(user.password, 12);
        }
      },
    },
    indexes: [
      { unique: true, fields: ['email'] },
      { unique: true, fields: ['username'] },
      { fields: ['role'] },
      { fields: ['isActive'] },
      { fields: ['parentId'] },
    ],
  }
);

module.exports = User;
