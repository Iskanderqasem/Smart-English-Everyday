const sgMail = require('@sendgrid/mail');
const nodemailer = require('nodemailer');
const logger = require('../../config/logger');
const {
  emailVerificationTemplate,
  passwordResetTemplate,
  welcomeTemplate,
  achievementTemplate,
  weeklyProgressTemplate,
} = require('../../utils/emailTemplates');

// Initialize SendGrid
if (process.env.SENDGRID_API_KEY) {
  sgMail.setApiKey(process.env.SENDGRID_API_KEY);
}

// Fallback SMTP transporter (nodemailer)
let smtpTransporter = null;
if (process.env.SMTP_HOST) {
  smtpTransporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT, 10) || 587,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
}

const FROM_EMAIL = process.env.FROM_EMAIL || 'noreply@smartenglisheveryday.com';
const FROM_NAME = process.env.FROM_NAME || 'Smart English Everyday';

/**
 * Send an email using SendGrid or SMTP fallback.
 */
const sendEmail = async ({ to, subject, html, text }) => {
  const msg = {
    to,
    from: { email: FROM_EMAIL, name: FROM_NAME },
    subject,
    html,
    text: text || html.replace(/<[^>]*>/g, ''),
  };

  try {
    if (process.env.SENDGRID_API_KEY) {
      await sgMail.send(msg);
      logger.info(`Email sent via SendGrid to ${to}: ${subject}`);
    } else if (smtpTransporter) {
      await smtpTransporter.sendMail({
        from: `"${FROM_NAME}" <${FROM_EMAIL}>`,
        to,
        subject,
        html,
        text: msg.text,
      });
      logger.info(`Email sent via SMTP to ${to}: ${subject}`);
    } else {
      logger.warn(`Email service not configured. Would have sent to ${to}: ${subject}`);
    }
    return true;
  } catch (error) {
    logger.error(`Failed to send email to ${to}:`, error);
    throw error;
  }
};

const sendVerificationEmail = async (user, verificationToken) => {
  const verificationUrl = `${process.env.APP_URL || 'http://localhost:3000'}/verify-email?token=${verificationToken}`;
  const template = emailVerificationTemplate({
    firstName: user.firstName,
    verificationUrl,
  });
  return sendEmail({ to: user.email, ...template });
};

const sendPasswordResetEmail = async (user, resetToken) => {
  const resetUrl = `${process.env.APP_URL || 'http://localhost:3000'}/reset-password?token=${resetToken}`;
  const template = passwordResetTemplate({
    firstName: user.firstName,
    resetUrl,
  });
  return sendEmail({ to: user.email, ...template });
};

const sendWelcomeEmail = async (user) => {
  const template = welcomeTemplate({
    firstName: user.firstName,
    dashboardUrl: `${process.env.APP_URL || 'http://localhost:3000'}/dashboard`,
  });
  return sendEmail({ to: user.email, ...template });
};

const sendAchievementEmail = async (user, achievement) => {
  const template = achievementTemplate({
    firstName: user.firstName,
    achievementName: achievement.name,
    achievementDescription: achievement.description,
    badgeIcon: achievement.badgeIcon,
    xpReward: achievement.xpReward,
  });
  return sendEmail({ to: user.email, ...template });
};

const sendWeeklyProgress = async (user, stats) => {
  const template = weeklyProgressTemplate({
    firstName: user.firstName,
    stats,
    dashboardUrl: `${process.env.APP_URL || 'http://localhost:3000'}/dashboard`,
  });
  return sendEmail({ to: user.email, ...template });
};

module.exports = {
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendAchievementEmail,
  sendWeeklyProgress,
};
