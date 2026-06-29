// Stub for non-web platforms (Android, iOS, desktop)
class TtsService {
  static bool get isSpeaking => false;
  static void speak(String text,
      {String lang = 'en-US', double rate = 0.85, double pitch = 1.0}) {}
  static void stop() {}
}
