const request = require('supertest');
const app = require('../../src/app');
const { sequelize, User } = require('../../src/models');

beforeAll(async () => {
  await sequelize.sync({ force: true });
});

afterAll(async () => {
  await sequelize.close();
});

describe('Auth API', () => {
  const testUser = {
    firstName: 'Test',
    lastName: 'User',
    username: 'testuser123',
    email: 'test@example.com',
    password: 'TestPassword123!',
    englishVariant: 'US',
  };

  describe('POST /api/auth/register', () => {
    it('should register a new user', async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.token).toBeDefined();
      expect(res.body.data.user.email).toBe(testUser.email);
      expect(res.body.data.user.password).toBeUndefined();
    });

    it('should reject duplicate email', async () => {
      const res = await request(app).post('/api/auth/register').send(testUser);
      expect(res.status).toBe(409);
    });

    it('should reject weak password', async () => {
      const res = await request(app).post('/api/auth/register').send({ ...testUser, email: 'new@test.com', password: '123' });
      expect(res.status).toBe(422);
    });
  });

  describe('POST /api/auth/login', () => {
    it('should login with valid credentials', async () => {
      const res = await request(app).post('/api/auth/login').send({ emailOrUsername: testUser.email, password: testUser.password });
      expect(res.status).toBe(200);
      expect(res.body.data.token).toBeDefined();
    });

    it('should reject invalid password', async () => {
      const res = await request(app).post('/api/auth/login').send({ emailOrUsername: testUser.email, password: 'wrongpassword' });
      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/auth/me', () => {
    it('should return current user when authenticated', async () => {
      const loginRes = await request(app).post('/api/auth/login').send({ emailOrUsername: testUser.email, password: testUser.password });
      const token = loginRes.body.data.token;

      const res = await request(app).get('/api/auth/me').set('Authorization', `Bearer ${token}`);
      expect(res.status).toBe(200);
      expect(res.body.data.user.email).toBe(testUser.email);
    });

    it('should reject unauthenticated requests', async () => {
      const res = await request(app).get('/api/auth/me');
      expect(res.status).toBe(401);
    });
  });

  describe('Health Check', () => {
    it('should return healthy status', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('ok');
    });
  });
});
