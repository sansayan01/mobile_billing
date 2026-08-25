import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class BeepHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool _fileReady = false;
  static String? _beepPath;

  /// Initialize - call once at app start
  static Future<void> init() async {
    try {
      final dir = await getTemporaryDirectory();
      _beepPath = '${dir.path}/scan_beep.wav';
      final file = File(_beepPath!);
      final bytes = _generateBeepWav(
        frequency: 1000,
        durationMs: 100,
        sampleRate: 22050,
        volume: 0.8,
      );
      await file.writeAsBytes(bytes);
      _fileReady = true;
    } catch (e) {
      _fileReady = false;
    }
  }

  /// Play a short beep sound
  static Future<void> playBeep() async {
    try {
      if (!_fileReady || _beepPath == null) {
        await init();
      }
      if (_fileReady && _beepPath != null) {
        await _player.play(DeviceFileSource(_beepPath!));
      }
    } catch (e) {
      // Silent fallback
    }
  }

  /// Generate a simple sine wave beep as WAV bytes
  static Uint8List _generateBeepWav({
    required int frequency,
    required int durationMs,
    required int sampleRate,
    required double volume,
  }) {
    final numSamples = (sampleRate * durationMs / 1000).round();
    const numChannels = 1;
    const bitsPerSample = 16;
    final byteRate = sampleRate * numChannels * bitsPerSample ~/ 8;
    const blockAlign = numChannels * bitsPerSample ~/ 8;
    final dataSize = numSamples * blockAlign;
    final fileSize = 44 + dataSize;

    final ByteData data = ByteData(fileSize);

    // WAV header
    data.setUint8(0, 0x52); // R
    data.setUint8(1, 0x49); // I
    data.setUint8(2, 0x46); // F
    data.setUint8(3, 0x46); // F
    data.setUint32(4, fileSize - 8, Endian.little);
    data.setUint8(8, 0x57); // W
    data.setUint8(9, 0x41); // A
    data.setUint8(10, 0x56); // V
    data.setUint8(11, 0x45); // E

    data.setUint8(12, 0x66); // f
    data.setUint8(13, 0x6D); // m
    data.setUint8(14, 0x74); // t
    data.setUint8(15, 0x20); // (space)
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);
    data.setUint16(22, numChannels, Endian.little);
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, byteRate, Endian.little);
    data.setUint16(32, blockAlign, Endian.little);
    data.setUint16(34, bitsPerSample, Endian.little);

    data.setUint8(36, 0x64); // d
    data.setUint8(37, 0x61); // a
    data.setUint8(38, 0x74); // t
    data.setUint8(39, 0x61); // a
    data.setUint32(40, dataSize, Endian.little);

    final fadeSamples = (sampleRate * 0.01).round();

    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final amplitude = volume * 32767;

      var sample = sin(2 * pi * frequency * t) * 0.7 +
          sin(2 * pi * frequency * 2 * t) * 0.2 +
          sin(2 * pi * frequency * 3 * t) * 0.1;
      sample *= amplitude;

      if (i < fadeSamples) {
        sample *= i / fadeSamples;
      } else if (i > numSamples - fadeSamples) {
        sample *= (numSamples - i) / fadeSamples;
      }

      final clampedSample = sample.clamp(-32768, 32767).toInt();
      data.setInt16(44 + i * 2, clampedSample, Endian.little);
    }

    return data.buffer.asUint8List();
  }

  /// Intentionally a NO-OP: [BeepHelper] is an app-lifetime singleton.
  /// Disposing the static player used to make every later [playBeep]
  /// fail silently. The OS reclaims the player on app exit anyway.
  static void dispose() {
    // Do not dispose _player — it must stay usable after this call.
  }
}
