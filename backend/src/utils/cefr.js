/**
 * CEFR Level Calculation Utilities
 */

const CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const CEFR_DESCRIPTORS = {
  A1: {
    label: 'Beginner',
    description: 'Can understand and use familiar everyday expressions and very basic phrases.',
    ieltsRange: [0, 2.5],
    toeflRange: [0, 30],
    levelNumber: 1,
  },
  A2: {
    label: 'Elementary',
    description:
      'Can understand sentences and frequently used expressions related to everyday topics.',
    ieltsRange: [2.5, 3.5],
    toeflRange: [31, 45],
    levelNumber: 2,
  },
  B1: {
    label: 'Intermediate',
    description: 'Can understand the main points of standard input on familiar matters.',
    ieltsRange: [3.5, 5.5],
    toeflRange: [46, 59],
    levelNumber: 3,
  },
  B2: {
    label: 'Upper Intermediate',
    description:
      'Can understand the main ideas of complex text on both concrete and abstract topics.',
    ieltsRange: [5.5, 6.5],
    toeflRange: [60, 78],
    levelNumber: 4,
  },
  C1: {
    label: 'Advanced',
    description: 'Can understand a wide range of demanding, longer texts and recognize implicit meaning.',
    ieltsRange: [6.5, 8.0],
    toeflRange: [79, 94],
    levelNumber: 5,
  },
  C2: {
    label: 'Proficiency',
    description: 'Can understand with ease virtually everything heard or read.',
    ieltsRange: [8.0, 9.0],
    toeflRange: [95, 120],
    levelNumber: 6,
  },
};

/**
 * Calculate CEFR level from assessment scores.
 * @param {Object} scores - { grammar, vocabulary, reading, listening, writing, speaking }
 * @returns {string} CEFR level
 */
const calculateCEFRLevel = (scores) => {
  const weights = {
    grammar: 0.2,
    vocabulary: 0.2,
    reading: 0.2,
    listening: 0.15,
    writing: 0.15,
    speaking: 0.1,
  };

  let weightedSum = 0;
  let totalWeight = 0;

  Object.entries(scores).forEach(([skill, score]) => {
    if (score !== null && score !== undefined && weights[skill]) {
      weightedSum += score * weights[skill];
      totalWeight += weights[skill];
    }
  });

  if (totalWeight === 0) return 'A1';

  const normalizedScore = weightedSum / totalWeight;

  if (normalizedScore < 25) return 'A1';
  if (normalizedScore < 40) return 'A2';
  if (normalizedScore < 55) return 'B1';
  if (normalizedScore < 70) return 'B2';
  if (normalizedScore < 85) return 'C1';
  return 'C2';
};

/**
 * Estimate IELTS band score from CEFR level and sub-scores.
 */
const estimateIELTS = (cefrLevel, scores = {}) => {
  const [min, max] = CEFR_DESCRIPTORS[cefrLevel]?.ieltsRange || [0, 2.5];
  const range = max - min;
  const avgScore = Object.values(scores).filter(Boolean).reduce((a, b) => a + b, 0) /
    (Object.values(scores).filter(Boolean).length || 1);
  const position = (avgScore % 10) / 10;
  const estimate = min + range * position;
  return Math.round(estimate * 2) / 2; // Round to nearest 0.5
};

/**
 * Estimate TOEFL score from CEFR level.
 */
const estimateTOEFL = (cefrLevel, scores = {}) => {
  const [min, max] = CEFR_DESCRIPTORS[cefrLevel]?.toeflRange || [0, 30];
  const range = max - min;
  const avgScore = Object.values(scores).filter(Boolean).reduce((a, b) => a + b, 0) /
    (Object.values(scores).filter(Boolean).length || 1);
  const position = (avgScore % 10) / 10;
  return Math.round(min + range * position);
};

/**
 * Get the next CEFR level.
 */
const getNextLevel = (currentLevel) => {
  const idx = CEFR_LEVELS.indexOf(currentLevel);
  if (idx === -1 || idx === CEFR_LEVELS.length - 1) return null;
  return CEFR_LEVELS[idx + 1];
};

/**
 * Get CEFR descriptor info.
 */
const getCEFRInfo = (level) => {
  return CEFR_DESCRIPTORS[level] || CEFR_DESCRIPTORS['A1'];
};

/**
 * Compare two CEFR levels.
 * Returns positive if a > b, negative if a < b, 0 if equal.
 */
const compareCEFR = (a, b) => {
  return CEFR_LEVELS.indexOf(a) - CEFR_LEVELS.indexOf(b);
};

module.exports = {
  CEFR_LEVELS,
  CEFR_DESCRIPTORS,
  calculateCEFRLevel,
  estimateIELTS,
  estimateTOEFL,
  getNextLevel,
  getCEFRInfo,
  compareCEFR,
};
