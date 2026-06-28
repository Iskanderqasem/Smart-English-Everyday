const speech = require('@google-cloud/speech');
const textToSpeech = require('@google-cloud/text-to-speech');
const logger = require('../../config/logger');

// Initialize Google Cloud clients
let speechClient = null;
let ttsClient = null;

const getSpeechClient = () => {
  if (!speechClient) {
    const config = {};
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      config.keyFilename = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    } else if (process.env.GOOGLE_CREDENTIALS_JSON) {
      config.credentials = JSON.parse(process.env.GOOGLE_CREDENTIALS_JSON);
    }
    speechClient = new speech.SpeechClient(config);
  }
  return speechClient;
};

const getTTSClient = () => {
  if (!ttsClient) {
    const config = {};
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      config.keyFilename = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    } else if (process.env.GOOGLE_CREDENTIALS_JSON) {
      config.credentials = JSON.parse(process.env.GOOGLE_CREDENTIALS_JSON);
    }
    ttsClient = new textToSpeech.TextToSpeechClient(config);
  }
  return ttsClient;
};

/**
 * Convert audio buffer to text using Google Cloud Speech-to-Text.
 * @param {Buffer} audioBuffer - Audio data buffer
 * @param {Object} config - STT configuration
 */
const speechToText = async (audioBuffer, config = {}) => {
  const client = getSpeechClient();

  const sttConfig = {
    encoding: config.encoding || 'WEBM_OPUS',
    sampleRateHertz: config.sampleRateHertz || 48000,
    languageCode: config.languageCode || 'en-US',
    enableAutomaticPunctuation: true,
    enableWordTimeOffsets: config.enableWordTimeOffsets || false,
    enableWordConfidence: true,
    model: config.model || 'latest_long',
    useEnhanced: true,
    speechContexts: config.speechContexts || [],
    ...config,
  };

  const audio = {
    content: audioBuffer.toString('base64'),
  };

  const request = { config: sttConfig, audio };

  const [response] = await client.recognize(request);

  if (!response.results || response.results.length === 0) {
    return { transcript: '', confidence: 0, words: [] };
  }

  const results = response.results.map((result) => {
    const alt = result.alternatives[0];
    return {
      transcript: alt.transcript,
      confidence: alt.confidence,
      words: alt.words || [],
    };
  });

  const fullTranscript = results.map((r) => r.transcript).join(' ');
  const avgConfidence =
    results.reduce((sum, r) => sum + r.confidence, 0) / results.length;

  logger.info(`STT completed: ${fullTranscript.length} chars, confidence: ${avgConfidence.toFixed(2)}`);

  return {
    transcript: fullTranscript,
    confidence: avgConfidence,
    words: results.flatMap((r) => r.words),
    results,
  };
};

/**
 * Convert text to speech using Google Cloud TTS.
 * @param {string} text - Text to synthesize
 * @param {Object} voiceConfig - Voice configuration
 * @returns {Buffer} Audio buffer (MP3)
 */
const textToSpeechConvert = async (text, voiceConfig = {}) => {
  const client = getTTSClient();

  const request = {
    input: voiceConfig.ssml ? { ssml: text } : { text },
    voice: {
      languageCode: voiceConfig.languageCode || 'en-US',
      name: voiceConfig.name || getVoiceName(voiceConfig.variant, voiceConfig.gender),
      ssmlGender: voiceConfig.gender || 'FEMALE',
    },
    audioConfig: {
      audioEncoding: 'MP3',
      speakingRate: voiceConfig.speakingRate || 1.0,
      pitch: voiceConfig.pitch || 0,
      volumeGainDb: voiceConfig.volumeGainDb || 0,
      effectsProfileId: voiceConfig.effectsProfileId || [],
    },
  };

  const [response] = await client.synthesizeSpeech(request);
  return Buffer.from(response.audioContent);
};

/**
 * Get Google TTS voice name based on variant and gender.
 */
const getVoiceName = (variant = 'US', gender = 'FEMALE') => {
  const voices = {
    US: { FEMALE: 'en-US-Neural2-F', MALE: 'en-US-Neural2-D' },
    UK: { FEMALE: 'en-GB-Neural2-A', MALE: 'en-GB-Neural2-B' },
    AU: { FEMALE: 'en-AU-Neural2-A', MALE: 'en-AU-Neural2-B' },
  };
  return voices[variant]?.[gender] || 'en-US-Neural2-F';
};

/**
 * Analyze pronunciation by comparing STT output with reference text.
 * Uses word-level alignment for detailed feedback.
 */
const analyzePronunciation = async (audioBuffer, referenceText, languageCode = 'en-US') => {
  const sttResult = await speechToText(audioBuffer, {
    languageCode,
    enableWordTimeOffsets: true,
    enableWordConfidence: true,
    speechContexts: [{ phrases: referenceText.split(' ') }],
  });

  const referenceWords = referenceText.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/);
  const transcriptWords = sttResult.transcript.toLowerCase().replace(/[^a-z0-9\s]/g, '').split(/\s+/);

  // Simple word alignment
  const wordErrors = [];
  let transcriptIdx = 0;

  referenceWords.forEach((refWord) => {
    const transcriptWord = transcriptWords[transcriptIdx];
    if (!transcriptWord) {
      wordErrors.push({ word: refWord, issue: 'skipped', studentSaid: null });
    } else if (refWord !== transcriptWord) {
      wordErrors.push({ word: refWord, issue: 'mispronounced', studentSaid: transcriptWord });
      transcriptIdx++;
    } else {
      transcriptIdx++;
    }
  });

  const totalWords = referenceWords.length;
  const errorCount = wordErrors.length;
  const accuracyScore = Math.max(0, Math.round(((totalWords - errorCount) / totalWords) * 100));
  const completenessScore = Math.round(Math.min(transcriptWords.length / totalWords, 1) * 100);

  // Estimate WPM from audio duration (approximate - if duration available)
  const durationSeconds = sttResult.words.length > 0
    ? parseFloat(sttResult.words[sttResult.words.length - 1]?.endTime?.seconds || 0)
    : null;
  const wpm = durationSeconds && durationSeconds > 0
    ? Math.round((transcriptWords.length / durationSeconds) * 60)
    : null;

  return {
    transcript: sttResult.transcript,
    accuracyScore,
    completenessScore,
    fluencyScore: Math.round((accuracyScore + completenessScore) / 2),
    wordErrors,
    wpm,
    confidence: sttResult.confidence,
  };
};

module.exports = {
  speechToText,
  textToSpeech: textToSpeechConvert,
  analyzePronunciation,
  getVoiceName,
};
