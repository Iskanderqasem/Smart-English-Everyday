// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

typedef OnResult = void Function(String transcript, bool isFinal);
typedef OnError = void Function(String error);

class SpeechRecognitionService {
  static bool get isAvailable {
    try {
      final stt = js.context['_SEE_STT'];
      if (stt == null) return false;
      return stt.callMethod('isAvailable', []) == true;
    } catch (_) {
      return false;
    }
  }

  static void start({
    required OnResult onResult,
    required OnError onError,
    void Function()? onEnd,
    String lang = 'en-US',
  }) {
    try {
      final stt = js.context['_SEE_STT'];
      if (stt == null) { onError('not-supported'); return; }

      stt.callMethod('start', [
        lang,
        js.allowInterop((String transcript, bool isFinal) {
          onResult(transcript, isFinal);
        }),
        js.allowInterop((String error) {
          onError(error);
        }),
        js.allowInterop(() {
          onEnd?.call();
        }),
      ]);
    } catch (e) {
      onError(e.toString());
    }
  }

  static void stop() {
    try {
      js.context['_SEE_STT']?.callMethod('stop', []);
    } catch (_) {}
  }
}

class SpeakingAnalyzer {
  static Map<String, dynamic> analyze(
      String transcript, int durationSeconds, String prompt) {
    final words = transcript.trim().isEmpty
        ? <String>[]
        : transcript.trim().toLowerCase().split(RegExp(r'\s+'));

    final wordCount = words.length;
    if (wordCount == 0) {
      return {
        'overall': 0, 'pronunciation': 0, 'fluency': 0, 'grammar': 0,
        'vocabulary': 0, 'confidence': 0, 'naturalness': 0,
        'wordCount': 0, 'wordsPerMinute': 0, 'uniqueWords': 0, 'sentenceCount': 0,
      };
    }

    final uniqueWords = words.toSet().length;
    final minutes = durationSeconds / 60.0;
    final wpm = minutes > 0 ? wordCount / minutes : 0.0;
    final sentences = transcript.split(RegExp(r'[.!?]+'));
    final sentenceCount = sentences.where((s) => s.trim().isNotEmpty).length;
    final avgWordsPerSentence = sentenceCount > 0 ? wordCount / sentenceCount : 0.0;
    final promptKeywords = prompt.toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 4)
        .toSet();
    final relevantHits = words.toSet().intersection(promptKeywords).length;

    final fluency = _clamp(_scoreWpm(wpm), 30, 98);
    final diversity = uniqueWords / wordCount;
    final vocabulary = _clamp((diversity * 110 + relevantHits * 4).round(), 35, 98);
    final grammar = _clamp(_scoreGrammar(avgWordsPerSentence, sentenceCount), 35, 96);
    final expectedWords = durationSeconds * 1.3;
    final confidence = _clamp((wordCount / expectedWords * 92).round(), 25, 98);
    final naturalness = _clamp(
        ((fluency * 0.4 + vocabulary * 0.3 + confidence * 0.3).round()) +
            (sentenceCount >= 3 ? 5 : 0),
        30, 97);
    final pronunciation = _clamp(((fluency + confidence) ~/ 2) + 3, 35, 97);
    final overall = ((pronunciation + fluency + grammar + vocabulary + confidence + naturalness) / 6).round();

    return {
      'overall': overall, 'pronunciation': pronunciation, 'fluency': fluency,
      'grammar': grammar, 'vocabulary': vocabulary, 'confidence': confidence,
      'naturalness': naturalness, 'wordCount': wordCount,
      'wordsPerMinute': wpm.round(), 'uniqueWords': uniqueWords,
      'sentenceCount': sentenceCount,
    };
  }

  static int _clamp(int v, int min, int max) =>
      v < min ? min : (v > max ? max : v);

  static int _scoreWpm(double wpm) {
    if (wpm < 30) return 30;
    if (wpm < 80) return (30 + (wpm - 30) * 0.7).round();
    if (wpm <= 145) return (65 + (wpm - 80) * 0.5).round();
    if (wpm <= 190) return (97 - (wpm - 145) * 0.6).round();
    return 40;
  }

  static int _scoreGrammar(double avg, int count) {
    int score = 50;
    if (avg >= 5 && avg <= 22) score += 25;
    else if (avg >= 3) score += 12;
    if (count >= 4) score += 20;
    else if (count >= 2) score += 10;
    return score;
  }

  static List<Map<String, String>> generateFeedback(
      Map<String, dynamic> scores, String transcript) {
    final items = <Map<String, String>>[];
    final overall = scores['overall'] as int;
    final wpm = scores['wordsPerMinute'] as int;
    final grammar = scores['grammar'] as int;
    final vocabulary = scores['vocabulary'] as int;
    final wordCount = scores['wordCount'] as int;
    final sentences = scores['sentenceCount'] as int;

    if (overall >= 80) {
      items.add({'type': 'good', 'text': 'Excellent performance! Clear, confident and well-structured.'});
    } else if (overall >= 60) {
      items.add({'type': 'good', 'text': 'Good effort! Your speaking is developing well. Keep practising daily.'});
    } else {
      items.add({'type': 'tip', 'text': 'Keep going — every session helps. Focus on speaking in full sentences.'});
    }

    if (wpm > 0 && wpm < 60) {
      items.add({'type': 'warn', 'text': 'You spoke quite slowly ($wpm wpm). Try to aim for 100-140 words per minute.'});
    } else if (wpm > 170) {
      items.add({'type': 'warn', 'text': 'You spoke very fast ($wpm wpm). Slow down and pause between ideas.'});
    } else if (wpm >= 90 && wpm <= 150) {
      items.add({'type': 'good', 'text': 'Your pace was natural and comfortable ($wpm wpm). Well done!'});
    }

    if (grammar < 60) {
      items.add({'type': 'warn', 'text': 'Focus on complete sentences — include a subject and verb in every idea.'});
    } else if (grammar >= 80) {
      items.add({'type': 'good', 'text': 'Great sentence structure! Varied and well-formed sentences.'});
    }

    if (vocabulary < 55) {
      items.add({'type': 'tip', 'text': 'Review topic vocabulary before speaking. Try to use a wider range of words.'});
    } else if (vocabulary >= 80) {
      items.add({'type': 'good', 'text': 'Impressive vocabulary range! You used diverse and relevant words.'});
    }

    if (wordCount < 15) {
      items.add({'type': 'warn', 'text': 'You only said $wordCount words. Try to speak for the full time.'});
    } else if (wordCount >= 80) {
      items.add({'type': 'good', 'text': 'Great response length! You spoke confidently and at length.'});
    }

    if (sentences == 1) {
      items.add({'type': 'tip', 'text': 'Try to break your speech into multiple sentences with different ideas.'});
    }

    return items;
  }
}
