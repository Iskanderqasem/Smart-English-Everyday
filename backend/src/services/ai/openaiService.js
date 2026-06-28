const OpenAI = require('openai');
const logger = require('../../config/logger');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const MODEL = process.env.OPENAI_MODEL || 'gpt-4o';
const TEACHER_SYSTEM_PROMPT = `You are an expert English language teacher with years of experience
teaching students at all levels from A1 to C2. You provide clear, encouraging, and accurate feedback.
Always be supportive and constructive. When correcting errors, explain the rule clearly.`;

/**
 * Analyze writing for grammar, vocabulary, structure, and coherence.
 */
const analyzeWriting = async (text, topic = '', taskType = 'essay') => {
  const prompt = `
Analyze the following ${taskType} written by an English language learner${topic ? ` on the topic: "${topic}"` : ''}.

Text to analyze:
"""
${text}
"""

Provide a JSON response with the following structure:
{
  "overallScore": <0-100>,
  "cefrLevel": "<A1|A2|B1|B2|C1|C2>",
  "grammarScore": <0-100>,
  "vocabularyScore": <0-100>,
  "coherenceScore": <0-100>,
  "structureScore": <0-100>,
  "wordCount": <number>,
  "corrections": [
    {
      "original": "<original text>",
      "corrected": "<corrected text>",
      "explanation": "<why it's wrong and the rule>",
      "type": "<grammar|vocabulary|spelling|punctuation|style>"
    }
  ],
  "correctedText": "<full corrected version of the text>",
  "generalFeedback": "<2-3 paragraphs of overall feedback>",
  "strengths": ["<strength 1>", "<strength 2>"],
  "improvements": ["<area to improve 1>", "<area to improve 2>"]
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.3,
    max_tokens: 3000,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Analyze and correct grammar in a text.
 */
const analyzeGrammar = async (text) => {
  const prompt = `
Identify and correct all grammar errors in the following text written by an English learner:
"""
${text}
"""

Return a JSON object:
{
  "hasErrors": <boolean>,
  "errorCount": <number>,
  "corrections": [
    {
      "original": "<original phrase>",
      "corrected": "<corrected phrase>",
      "rule": "<grammar rule violated>",
      "explanation": "<clear explanation>",
      "type": "<tense|agreement|article|preposition|word_order|punctuation|other>"
    }
  ],
  "correctedText": "<full corrected text>",
  "overallGrammarScore": <0-100>,
  "feedback": "<brief encouraging feedback>"
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.2,
    max_tokens: 2000,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Generate a clear explanation of an English concept or grammar rule.
 */
const generateExplanation = async (concept, cefrLevel = 'B1') => {
  const prompt = `
Explain the English concept/rule: "${concept}"
Target student level: ${cefrLevel}

Provide a JSON response:
{
  "concept": "${concept}",
  "explanation": "<clear explanation appropriate for ${cefrLevel} level>",
  "examples": [
    { "correct": "<example>", "incorrect": "<wrong version>", "note": "<why>" }
  ],
  "commonMistakes": ["<mistake 1>", "<mistake 2>"],
  "tips": ["<tip 1>", "<tip 2>"],
  "relatedConcepts": ["<related concept>"]
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.4,
    max_tokens: 1500,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Generate a conversation response for the AI chatbot.
 */
const generateConversation = async (topic, userMessage, history = [], cefrLevel = 'B1') => {
  const systemPrompt = `${TEACHER_SYSTEM_PROMPT}
Current conversation topic: ${topic}
Student's CEFR level: ${cefrLevel}
Adapt your language complexity to ${cefrLevel} level.
Gently correct grammar errors in the student's messages when they occur.
Keep responses conversational and engaging (2-4 sentences typically).`;

  const messages = [
    { role: 'system', content: systemPrompt },
    ...history.slice(-10), // Keep last 10 messages for context
    { role: 'user', content: userMessage },
  ];

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages,
    temperature: 0.7,
    max_tokens: 500,
  });

  const assistantMessage = response.choices[0].message.content;

  // Check for grammar corrections in user's message
  let corrections = [];
  try {
    const grammarCheck = await analyzeGrammar(userMessage);
    if (grammarCheck.hasErrors) {
      corrections = grammarCheck.corrections;
    }
  } catch {
    // Non-fatal - continue without corrections
  }

  return {
    message: assistantMessage,
    corrections,
    tokens: response.usage?.total_tokens,
  };
};

/**
 * Assess pronunciation from STT transcript vs reference text.
 */
const assessPronunciation = async (transcript, referenceText) => {
  const prompt = `
Compare a student's spoken English transcript with the reference text and assess pronunciation:

Reference text:
"""${referenceText}"""

Student's transcript (from Speech-to-Text):
"""${transcript}"""

Provide a JSON assessment:
{
  "accuracyScore": <0-100>,
  "fluencyScore": <0-100>,
  "completenessScore": <0-100>,
  "overallScore": <0-100>,
  "wordErrors": [
    {
      "word": "<word from reference>",
      "issue": "<mispronounced|skipped|substituted>",
      "studentSaid": "<what student said or null>",
      "tip": "<pronunciation tip>"
    }
  ],
  "feedback": "<encouraging feedback with specific pronunciation tips>",
  "wpm": <estimated words per minute or null>
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.2,
    max_tokens: 1500,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Estimate CEFR level from assessment data.
 */
const estimateCEFRLevel = async (assessmentData) => {
  const prompt = `
Based on the following English assessment data, determine the student's CEFR level:

${JSON.stringify(assessmentData, null, 2)}

Provide a JSON response:
{
  "cefrLevel": "<A1|A2|B1|B2|C1|C2>",
  "confidence": <0-100>,
  "ieltsEstimate": <0-9 in 0.5 increments>,
  "toeflEstimate": <0-120>,
  "skillBreakdown": {
    "grammar": "<level>",
    "vocabulary": "<level>",
    "reading": "<level>",
    "listening": "<level>",
    "writing": "<level>",
    "speaking": "<level>"
  },
  "strengths": ["<strength>"],
  "weaknesses": ["<weakness>"],
  "recommendations": ["<specific recommendation>"],
  "estimatedWeeksToNextLevel": <number>
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.2,
    max_tokens: 1500,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Generate a personalized learning plan.
 */
const generatePersonalizedPlan = async (userProfile) => {
  const prompt = `
Create a personalized English learning plan for a student:

Profile:
${JSON.stringify(userProfile, null, 2)}

Provide a JSON learning plan:
{
  "weeklyGoal": "<specific weekly learning goal>",
  "dailyMinutes": <recommended daily study minutes>,
  "prioritySkills": ["<skill1>", "<skill2>"],
  "weeklyPlan": [
    {
      "day": "<Monday|Tuesday|...>",
      "focus": "<skill focus>",
      "activities": ["<activity 1>", "<activity 2>"],
      "durationMinutes": <number>
    }
  ],
  "milestones": [
    {
      "week": <number>,
      "goal": "<milestone goal>",
      "metric": "<how to measure>"
    }
  ],
  "recommendedResources": ["<resource>"],
  "estimatedTimeToGoal": "<e.g., 3 months>",
  "motivationalMessage": "<personalized encouragement>"
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.5,
    max_tokens: 2000,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Generate a word of the day with full details.
 */
const generateDailyWord = async (cefrLevel = 'B1', category = null) => {
  const prompt = `
Generate an interesting and useful English word of the day${category ? ` related to ${category}` : ''} suitable for a ${cefrLevel} level learner.

Return a JSON object:
{
  "word": "<word>",
  "partOfSpeech": "<noun|verb|adjective|adverb|etc>",
  "phonetic": "<IPA phonetic notation>",
  "definition": "<clear definition>",
  "definitions": [
    { "meaning": "<definition>", "context": "<formal|informal|technical>" }
  ],
  "examples": ["<example sentence 1>", "<example sentence 2>", "<example sentence 3>"],
  "synonyms": ["<synonym1>", "<synonym2>"],
  "antonyms": ["<antonym1>", "<antonym2>"],
  "etymology": "<brief word origin>",
  "memoryTip": "<fun way to remember this word>",
  "collocations": ["<common phrase with the word>"],
  "cefrLevel": "${cefrLevel}",
  "usageTip": "<when and how to use this word>"
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.7,
    max_tokens: 1000,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Translate text to a target language.
 */
const translateText = async (text, targetLanguage) => {
  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      {
        role: 'system',
        content: `You are a professional translator. Translate text accurately to ${targetLanguage}. Return only the translation.`,
      },
      { role: 'user', content: text },
    ],
    temperature: 0.1,
    max_tokens: 1000,
  });

  return { translation: response.choices[0].message.content.trim(), targetLanguage };
};

/**
 * Check spelling and return corrections.
 */
const checkSpelling = async (text) => {
  const prompt = `
Check the spelling in the following text:
"""${text}"""

Return a JSON object:
{
  "hasErrors": <boolean>,
  "corrections": [
    { "original": "<misspelled>", "corrected": "<correct>", "position": <word index> }
  ],
  "correctedText": "<full text with spelling fixed>"
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [{ role: 'user', content: prompt }],
    response_format: { type: 'json_object' },
    temperature: 0.1,
    max_tokens: 500,
  });

  return JSON.parse(response.choices[0].message.content);
};

/**
 * Analyze a speaking session transcript for fluency/grammar/vocabulary.
 */
const analyzeSpeaking = async (transcript, topic, taskType = 'discuss_topic') => {
  const prompt = `
Analyze this speaking response by an English language learner:

Task: ${taskType} - "${topic}"
Transcript: """${transcript}"""

Return a JSON assessment:
{
  "grammarScore": <0-100>,
  "vocabularyScore": <0-100>,
  "fluencyScore": <0-100>,
  "coherenceScore": <0-100>,
  "overallScore": <0-100>,
  "cefrLevel": "<A1|A2|B1|B2|C1|C2>",
  "wordCount": <number>,
  "corrections": [
    { "original": "<error>", "corrected": "<fix>", "explanation": "<rule>" }
  ],
  "vocabularyHighlights": ["<good word usage>"],
  "feedback": "<detailed constructive feedback>",
  "strengths": ["<strength>"],
  "improvements": ["<specific improvement>"]
}`;

  const response = await openai.chat.completions.create({
    model: MODEL,
    messages: [
      { role: 'system', content: TEACHER_SYSTEM_PROMPT },
      { role: 'user', content: prompt },
    ],
    response_format: { type: 'json_object' },
    temperature: 0.3,
    max_tokens: 2000,
  });

  return JSON.parse(response.choices[0].message.content);
};

module.exports = {
  analyzeWriting,
  analyzeGrammar,
  generateExplanation,
  generateConversation,
  assessPronunciation,
  estimateCEFRLevel,
  generatePersonalizedPlan,
  generateDailyWord,
  translateText,
  checkSpelling,
  analyzeSpeaking,
};
