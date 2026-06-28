module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/tests/**/*.test.js', '**/?(*.)+(spec|test).js'],
  collectCoverageFrom: ['src/**/*.js', '!src/jobs/**', '!src/config/swagger.js'],
  coverageThreshold: { global: { branches: 70, functions: 80, lines: 80, statements: 80 } },
  setupFilesAfterFramework: ['./tests/setup.js'],
  testTimeout: 30000,
};
