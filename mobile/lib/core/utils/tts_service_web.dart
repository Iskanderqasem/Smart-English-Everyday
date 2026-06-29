// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class TtsService {
  static bool _speaking = false;
  static void Function()? _pendingOnEnd;

  static bool get isSpeaking => _speaking;

  static void speak(String text,
      {String lang = 'en-US',
      double rate = 0.85,
      double pitch = 1.0,
      void Function()? onEnd}) {
    try {
      final synth = html.window.speechSynthesis;
      if (synth == null) return;
      synth.cancel();
      _speaking = false;
      _pendingOnEnd = onEnd;

      void doSpeak() {
        try {
          final utterance = html.SpeechSynthesisUtterance(text)
            ..lang = lang
            ..rate = rate
            ..pitch = pitch;
          utterance.addEventListener('start', (_) => _speaking = true);
          utterance.addEventListener('end', (_) {
            _speaking = false;
            _pendingOnEnd?.call();
            _pendingOnEnd = null;
          });
          utterance.addEventListener('error', (_) {
            _speaking = false;
            _pendingOnEnd?.call();
            _pendingOnEnd = null;
          });
          synth!.speak(utterance);
        } catch (_) {
          _speaking = false;
        }
      }

      // Wait for voices to load — required on Android Chrome and some mobile browsers
      final voices = synth.getVoices();
      if (voices == null || voices.isEmpty) {
        synth.addEventListener('voiceschanged', (_) => doSpeak());
        // Fallback: try anyway after a short delay in case voiceschanged doesn't fire
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!_speaking) doSpeak();
        });
      } else {
        doSpeak();
      }
    } catch (_) {
      _speaking = false;
    }
  }

  static void stop() {
    try {
      html.window.speechSynthesis?.cancel();
      _speaking = false;
      _pendingOnEnd = null;
    } catch (_) {}
  }
}
