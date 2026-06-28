const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

class Word extends Model {}

Word.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    word: {
      type: DataTypes.STRING(100),
      allowNull: false,
    },
    phonetic: {
      type: DataTypes.STRING(200),
      allowNull: true,
    },
    phoneticUK: {
      type: DataTypes.STRING(200),
      allowNull: true,
    },
    phoneticUS: {
      type: DataTypes.STRING(200),
      allowNull: true,
    },
    partOfSpeech: {
      type: DataTypes.ENUM(
        'noun',
        'verb',
        'adjective',
        'adverb',
        'preposition',
        'conjunction',
        'pronoun',
        'interjection',
        'article',
        'phrase'
      ),
      allowNull: true,
    },
    definition: {
      type: DataTypes.TEXT,
      allowNull: false,
    },
    definitions: {
      type: DataTypes.JSONB,
      defaultValue: [],
      comment: 'Multiple definitions with usage context',
    },
    examples: {
      type: DataTypes.ARRAY(DataTypes.TEXT),
      defaultValue: [],
    },
    synonyms: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: [],
    },
    antonyms: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: [],
    },
    audioUrlUK: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    audioUrlUS: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    imageUrl: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    cefrLevel: {
      type: DataTypes.ENUM('A1', 'A2', 'B1', 'B2', 'C1', 'C2'),
      allowNull: true,
    },
    frequency: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
      comment: 'Word frequency rank',
    },
    category: {
      type: DataTypes.STRING(100),
      allowNull: true,
    },
    tags: {
      type: DataTypes.ARRAY(DataTypes.STRING),
      defaultValue: [],
    },
    isDailyWord: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    lastUsedAsDaily: {
      type: DataTypes.DATE,
      allowNull: true,
    },
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    collocations: {
      type: DataTypes.JSONB,
      defaultValue: [],
    },
    etymology: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
  },
  {
    sequelize,
    modelName: 'Word',
    tableName: 'Words',
    indexes: [
      { fields: ['word'] },
      { fields: ['cefrLevel'] },
      { fields: ['partOfSpeech'] },
      { fields: ['isDailyWord'] },
      { fields: ['category'] },
    ],
  }
);

module.exports = Word;
