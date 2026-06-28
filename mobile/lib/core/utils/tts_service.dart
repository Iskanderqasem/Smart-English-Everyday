// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class TtsService {
  static bool _speaking = false;

  static bool get isSpeaking => _speaking;

  static void speak(String text, {String lang = 'en-US', double rate = 0.85, double pitch = 1.0}) {
    try {
      final synth = html.window.speechSynthesis;
      if (synth == null) return;
      synth.cancel();
      final utterance = html.SpeechSynthesisUtterance(text)
        ..lang = lang
        ..rate = rate
        ..pitch = pitch;
      utterance.addEventListener('start', (_) => _speaking = true);
      utterance.addEventListener('end', (_) => _speaking = false);
      utterance.addEventListener('error', (_) => _speaking = false);
      synth.speak(utterance);
      _speaking = true;
    } catch (_) {}
  }

  static void stop() {
    try {
      html.window.speechSynthesis?.cancel();
      _speaking = false;
    } catch (_) {}
  }
}
