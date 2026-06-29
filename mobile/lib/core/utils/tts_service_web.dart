// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class TtsService {
  static bool get isSpeaking {
    try {
      return js.context['_SEE_TTS']?.callMethod('isSpeaking', []) as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  static void speak(String text,
      {String lang = 'en-US',
      double rate = 0.85,
      double pitch = 1.0,
      void Function()? onEnd}) {
    try {
      final tts = js.context['_SEE_TTS'];
      if (tts == null) return;
      if (onEnd != null) {
        tts.callMethod('setOnEnd', [js.allowInterop(onEnd)]);
      }
      tts.callMethod('speak', [text, lang, rate]);
    } catch (_) {}
  }

  static void stop() {
    try {
      js.context['_SEE_TTS']?.callMethod('stop', []);
    } catch (_) {}
  }
}
