const passport = require('passport');
const { Strategy: JwtStrategy, ExtractJwt } = require('passport-jwt');
const GoogleStrategy = require('passport-google-oauth20').Strategy;
const FacebookStrategy = require('passport-facebook').Strategy;
const { User } = require('../models');
const logger = require('./logger');

const configurePassport = () => {
  // JWT Strategy
  passport.use(
    new JwtStrategy(
      {
        jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
        secretOrKey: process.env.JWT_SECRET,
        issuer: process.env.JWT_ISSUER || 'smart-english-everyday',
        audience: process.env.JWT_AUDIENCE || 'smart-english-everyday-users',
      },
      async (payload, done) => {
        try {
          const user = await User.findOne({
            where: { id: payload.sub, isActive: true },
            attributes: { exclude: ['password', 'twoFactorSecret'] },
          });

          if (!user) {
            return done(null, false, { message: 'User not found or inactive.' });
          }

          return done(null, user);
        } catch (error) {
          logger.error('JWT Strategy error:', error);
          return done(error, false);
        }
      }
    )
  );

  // Google OAuth2 Strategy
  if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
    passport.use(
      new GoogleStrategy(
        {
          clientID: process.env.GOOGLE_CLIENT_ID,
          clientSecret: process.env.GOOGLE_CLIENT_SECRET,
          callbackURL: process.env.GOOGLE_CALLBACK_URL || '/api/auth/google/callback',
          scope: ['profile', 'email'],
        },
        async (accessToken, refreshToken, profile, done) => {
          try {
            const email = profile.emails?.[0]?.value;
            if (!email) {
              return done(null, false, { message: 'No email from Google.' });
            }

            let user = await User.findOne({ where: { googleId: profile.id } });

            if (!user) {
              user = await User.findOne({ where: { email } });
              if (user) {
                await user.update({ googleId: profile.id });
              } else {
                user = await User.create({
                  googleId: profile.id,
                  email,
                  firstName: profile.name?.givenName || '',
                  lastName: profile.name?.familyName || '',
                  username: `user_${profile.id.slice(0, 8)}`,
                  avatar: profile.photos?.[0]?.value || null,
                  isEmailVerified: true,
                  isActive: true,
                });
              }
            }

            return done(null, user);
          } catch (error) {
            logger.error('Google Strategy error:', error);
            return done(error, false);
          }
        }
      )
    );
  }

  // Facebook OAuth Strategy
  if (process.env.FACEBOOK_APP_ID && process.env.FACEBOOK_APP_SECRET) {
    passport.use(
      new FacebookStrategy(
        {
          clientID: process.env.FACEBOOK_APP_ID,
          clientSecret: process.env.FACEBOOK_APP_SECRET,
          callbackURL: process.env.FACEBOOK_CALLBACK_URL || '/api/auth/facebook/callback',
          profileFields: ['id', 'emails', 'name', 'picture.type(large)'],
        },
        async (accessToken, refreshToken, profile, done) => {
          try {
            const email = profile.emails?.[0]?.value;

            let user = await User.findOne({ where: { facebookId: profile.id } });

            if (!user) {
              if (email) {
                user = await User.findOne({ where: { email } });
                if (user) {
                  await user.update({ facebookId: profile.id });
                }
              }

              if (!user) {
                user = await User.create({
                  facebookId: profile.id,
                  email: email || null,
                  firstName: profile.name?.givenName || '',
                  lastName: profile.name?.familyName || '',
                  username: `fb_${profile.id.slice(0, 8)}`,
                  avatar: profile.photos?.[0]?.value || null,
                  isEmailVerified: !!email,
                  isActive: true,
                });
              }
            }

            return done(null, user);
          } catch (error) {
            logger.error('Facebook Strategy error:', error);
            return done(error, false);
          }
        }
      )
    );
  }

  passport.serializeUser((user, done) => done(null, user.id));
  passport.deserializeUser(async (id, done) => {
    try {
      const user = await User.findByPk(id);
      done(null, user);
    } catch (error) {
      done(error, null);
    }
  });
};

module.exports = configurePassport;
