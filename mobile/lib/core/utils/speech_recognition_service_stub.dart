// Stub for non-web platforms (Android, iOS, desktop)
typedef OnResult = void Function(String transcript, bool isFinal);
typedef OnError = void Function(String error);

class SpeechRecognitionService {
  static bool get isAvailable => false;
  static void start({
    required OnResult onResult,
    required OnError onError,
    void Function()? onEnd,
    String lang = 'en-US',
  }) {
    onError('Speech recognition is only available in the web browser.');
  }
  static void stop() {}
}

class SpeakingAnalyzer {
  static Map<String, dynamic> analyze(
      String transcript, int durationSeconds, String prompt) =>
      {
        'overall': 0, 'pronunciation': 0, 'fluency': 0, 'grammar': 0,
        'vocabulary': 0, 'confidence': 0, 'naturalness': 0,
        'wordCount': 0, 'wordsPerMinute': 0, 'uniqueWords': 0, 'sentenceCount': 0,
      };

  static List<Map<String, String>> generateFeedback(
      Map<String, dynamic> scores, String transcript) =>
      [{'type': 'tip', 'text': 'Speech practice is available in the web version of this app.'}];
}
