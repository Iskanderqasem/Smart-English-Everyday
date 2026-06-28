const dayjs = require('dayjs');

const baseStyle = `
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background-color: #f8fafc;
  margin: 0;
  padding: 0;
`;

const containerStyle = `
  max-width: 600px;
  margin: 40px auto;
  background: #ffffff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0,0,0,0.07);
`;

const headerStyle = `
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  padding: 40px 32px;
  text-align: center;
`;

const bodyStyle = `padding: 40px 32px;`;

const footerStyle = `
  background: #f1f5f9;
  padding: 24px 32px;
  text-align: center;
  font-size: 13px;
  color: #64748b;
`;

const buttonStyle = `
  display: inline-block;
  padding: 14px 32px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  color: #ffffff !important;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 16px;
  margin: 24px 0;
`;

const wrapHtml = (title, content) => `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
</head>
<body style="${baseStyle}">
  <div style="${containerStyle}">
    <div style="${headerStyle}">
      <img src="${process.env.APP_LOGO_URL || ''}" alt="Smart English Everyday" width="48" style="margin-bottom:12px;" />
      <h1 style="color:#ffffff;margin:0;font-size:24px;font-weight:700;">Smart English Everyday</h1>
    </div>
    <div style="${bodyStyle}">
      ${content}
    </div>
    <div style="${footerStyle}">
      <p style="margin:0 0 8px;">&copy; ${dayjs().year()} Smart English Everyday. All rights reserved.</p>
      <p style="margin:0;">
        <a href="${process.env.APP_URL || '#'}/privacy" style="color:#6366f1;text-decoration:none;">Privacy Policy</a> &middot;
        <a href="${process.env.APP_URL || '#'}/terms" style="color:#6366f1;text-decoration:none;">Terms of Service</a>
      </p>
    </div>
  </div>
</body>
</html>
`;

const emailVerificationTemplate = ({ firstName, verificationUrl }) => ({
  subject: 'Verify your email - Smart English Everyday',
  html: wrapHtml(
    'Verify your email',
    `
    <h2 style="color:#1e293b;margin:0 0 16px;">Welcome, ${firstName || 'Learner'}! 🎉</h2>
    <p style="color:#475569;line-height:1.6;margin:0 0 16px;">
      Thank you for joining Smart English Everyday. You're one step away from starting your
      English learning journey!
    </p>
    <p style="color:#475569;line-height:1.6;margin:0 0 24px;">
      Please verify your email address by clicking the button below. This link expires in <strong>24 hours</strong>.
    </p>
    <div style="text-align:center;">
      <a href="${verificationUrl}" style="${buttonStyle}">Verify My Email</a>
    </div>
    <p style="color:#94a3b8;font-size:13px;margin:24px 0 0;">
      Or copy and paste this URL: <br>
      <a href="${verificationUrl}" style="color:#6366f1;word-break:break-all;">${verificationUrl}</a>
    </p>
    <p style="color:#94a3b8;font-size:13px;margin:16px 0 0;">
      If you didn't create this account, you can safely ignore this email.
    </p>
    `
  ),
});

const passwordResetTemplate = ({ firstName, resetUrl }) => ({
  subject: 'Reset your password - Smart English Everyday',
  html: wrapHtml(
    'Reset your password',
    `
    <h2 style="color:#1e293b;margin:0 0 16px;">Password Reset Request</h2>
    <p style="color:#475569;line-height:1.6;margin:0 0 16px;">
      Hi ${firstName || 'there'}, we received a request to reset the password for your Smart English Everyday account.
    </p>
    <p style="color:#475569;line-height:1.6;margin:0 0 24px;">
      Click the button below to set a new password. This link expires in <strong>1 hour</strong>.
    </p>
    <div style="text-align:center;">
      <a href="${resetUrl}" style="${buttonStyle}">Reset My Password</a>
    </div>
    <p style="color:#94a3b8;font-size:13px;margin:24px 0 0;">
      Or copy and paste this URL: <br>
      <a href="${resetUrl}" style="color:#6366f1;word-break:break-all;">${resetUrl}</a>
    </p>
    <p style="color:#94a3b8;font-size:13px;margin:16px 0 0;">
      If you didn't request a password reset, please ignore this email or contact support if you have concerns.
    </p>
    `
  ),
});

const welcomeTemplate = ({ firstName, dashboardUrl }) => ({
  subject: 'Welcome to Smart English Everyday! 🚀',
  html: wrapHtml(
    'Welcome!',
    `
    <h2 style="color:#1e293b;margin:0 0 16px;">You're all set, ${firstName || 'Learner'}! 🚀</h2>
    <p style="color:#475569;line-height:1.6;margin:0 0 16px;">
      Welcome to Smart English Everyday — your AI-powered path to English fluency. Here's what you can do:
    </p>
    <ul style="color:#475569;line-height:2;padding-left:20px;">
      <li>📊 Take a <strong>placement assessment</strong> to find your level</li>
      <li>📚 Work through <strong>personalized lessons</strong> tailored to your goals</li>
      <li>🎤 Practice <strong>speaking</strong> with AI pronunciation feedback</li>
      <li>✍️ Get <strong>writing feedback</strong> with grammar corrections</li>
      <li>🏆 Earn <strong>achievements</strong> and maintain your streak</li>
    </ul>
    <div style="text-align:center;">
      <a href="${dashboardUrl || process.env.APP_URL + '/dashboard'}" style="${buttonStyle}">Start Learning Now</a>
    </div>
    `
  ),
});

const achievementTemplate = ({ firstName, achievementName, achievementDescription, badgeIcon, xpReward }) => ({
  subject: `🏆 Achievement Unlocked: ${achievementName}!`,
  html: wrapHtml(
    'Achievement Unlocked!',
    `
    <div style="text-align:center;margin-bottom:24px;">
      <div style="font-size:64px;">${badgeIcon || '🏆'}</div>
      <h2 style="color:#1e293b;margin:8px 0 4px;">Achievement Unlocked!</h2>
      <p style="color:#6366f1;font-weight:700;font-size:20px;margin:0;">${achievementName}</p>
    </div>
    <p style="color:#475569;line-height:1.6;margin:0 0 16px;">
      Congratulations, ${firstName || 'Learner'}! You've earned a new achievement:
    </p>
    <div style="background:#f1f5f9;border-radius:8px;padding:20px;margin:0 0 24px;">
      <p style="color:#1e293b;margin:0;font-size:16px;">${achievementDescription}</p>
      ${xpReward ? `<p style="color:#6366f1;font-weight:700;margin:12px 0 0;">+${xpReward} XP earned!</p>` : ''}
    </div>
    <div style="text-align:center;">
      <a href="${process.env.APP_URL || '#'}/achievements" style="${buttonStyle}">View All Achievements</a>
    </div>
    `
  ),
});

const weeklyProgressTemplate = ({ firstName, stats, dashboardUrl }) => ({
  subject: `Your weekly progress report 📈`,
  html: wrapHtml(
    'Weekly Progress Report',
    `
    <h2 style="color:#1e293b;margin:0 0 8px;">Weekly Progress Report</h2>
    <p style="color:#64748b;margin:0 0 24px;">Week of ${dayjs().subtract(7, 'day').format('MMMM D')} - ${dayjs().format('MMMM D, YYYY')}</p>
    <p style="color:#475569;line-height:1.6;margin:0 0 24px;">
      Hi ${firstName || 'Learner'}! Here's a summary of your learning this week:
    </p>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin:0 0 24px;">
      ${[
        { label: 'Lessons Completed', value: stats?.lessonsCompleted || 0, icon: '📚' },
        { label: 'XP Earned', value: `${stats?.xpEarned || 0} XP`, icon: '⚡' },
        { label: 'Streak', value: `${stats?.currentStreak || 0} days`, icon: '🔥' },
        { label: 'Study Time', value: `${stats?.studyMinutes || 0} min`, icon: '⏱️' },
      ].map(({ label, value, icon }) => `
        <div style="background:#f8fafc;border-radius:8px;padding:16px;text-align:center;">
          <div style="font-size:28px;margin-bottom:8px;">${icon}</div>
          <div style="font-size:22px;font-weight:700;color:#1e293b;">${value}</div>
          <div style="font-size:13px;color:#64748b;">${label}</div>
        </div>
      `).join('')}
    </div>
    <div style="text-align:center;">
      <a href="${dashboardUrl || process.env.APP_URL + '/dashboard'}" style="${buttonStyle}">View Full Dashboard</a>
    </div>
    `
  ),
});

module.exports = {
  emailVerificationTemplate,
  passwordResetTemplate,
  welcomeTemplate,
  achievementTemplate,
  weeklyProgressTemplate,
};
