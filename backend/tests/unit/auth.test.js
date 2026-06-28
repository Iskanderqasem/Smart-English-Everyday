const { hashPassword, comparePassword } = require('../../src/utils/passwordUtils');
const { generateToken, verifyToken } = require('../../src/utils/tokenUtils');
const { scoreToCEFR, cefrToExamScores } = require('../../src/utils/cefr');

describe('Password Utils', () => {
  it('should hash a password', async () => {
    const hash = await hashPassword('TestPassword123!');
    expect(hash).toBeDefined();
    expect(hash).not.toBe('TestPassword123!');
  });

  it('should verify a correct password', async () => {
    const hash = await hashPassword('TestPassword123!');
    const result = await comparePassword('TestPassword123!', hash);
    expect(result).toBe(true);
  });

  it('should reject an incorrect password', async () => {
    const hash = await hashPassword('TestPassword123!');
    const result = await comparePassword('WrongPassword', hash);
    expect(result).toBe(false);
  });
});

describe('Token Utils', () => {
  it('should generate and verify a JWT token', () => {
    process.env.JWT_SECRET = 'test_secret_for_unit_tests';
    const token = generateToken('user-123');
    const decoded = verifyToken(token, process.env.JWT_SECRET);
    expect(decoded.id).toBe('user-123');
  });
});

describe('CEFR Scoring', () => {
  it('should map scores to CEFR levels', () => {
    expect(scoreToCEFR(20)).toBe('A1');
    expect(scoreToCEFR(35)).toBe('A2');
    expect(scoreToCEFR(50)).toBe('B1');
    expect(scoreToCEFR(65)).toBe('B2');
    expect(scoreToCEFR(80)).toBe('C1');
    expect(scoreToCEFR(95)).toBe('C2');
  });

  it('should map CEFR to IELTS/TOEFL estimates', () => {
    const scores = cefrToExamScores('B1');
    expect(scores.ielts).toBeDefined();
    expect(scores.toefl).toBeDefined();
  });
});
