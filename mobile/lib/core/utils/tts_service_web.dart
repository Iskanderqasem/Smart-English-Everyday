// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class TtsService {
  static bool get isSpeaking {
    try {
      return js.context['speechSynthesis']?['speaking'] as bool? ?? false;
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
      final synth = js.context['speechSynthesis'];
      if (synth == null) {
        onEnd?.call();
        return;
      }

      synth.callMethod('cancel', []);

      final ctor = js.context['SpeechSynthesisUtterance'];
      if (ctor == null) {
        onEnd?.call();
        return;
      }

      final u = js.JsObject(ctor as js.JsFunction, [text]);
      u['lang'] = lang;
      u['rate'] = rate;
      u['pitch'] = pitch;

      if (onEnd != null) {
        u['onend'] = js.allowInterop((_) => onEnd());
        u['onerror'] = js.allowInterop((_) => onEnd());
      }

      synth.callMethod('speak', [u]);

      // Chrome Android: resume if synthesis is paused (background tab bug)
      js.context.callMethod('setTimeout', [
        js.allowInterop(() {
          try {
            if (synth['paused'] == true) synth.callMethod('resume', []);
          } catch (_) {}
        }),
        100,
      ]);
    } catch (_) {
      onEnd?.call();
    }
  }

  static void stop() {
    try {
      js.context['speechSynthesis']?.callMethod('cancel', []);
    } catch (_) {}
  }
}
