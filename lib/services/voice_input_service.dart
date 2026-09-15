import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'ai_service.dart';

/// Wraps microphone recording (`record` package) and Whisper transcription
/// ([AiService.transcribe]) behind a tiny start/stop API, shared by the MBMT
/// Assistant's voice input and the Home search bar's mic button.
class VoiceInputService {
  VoiceInputService._();
  static final VoiceInputService instance = VoiceInputService._();

  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  bool get isRecording => _recording;

  /// Starts recording. Returns false if microphone permission was denied.
  Future<bool> start() async {
    if (_recording) return true;

    final bool granted = await _recorder.hasPermission();
    if (!granted) return false;

    final Directory dir = await getTemporaryDirectory();
    final String path = '${dir.path}/mbmt_voice_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 24000,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
      path: path,
    );
    _recording = true;
    return true;
  }

  /// Stops recording and returns the transcript, or null if nothing usable
  /// was captured. Throws [AiServiceException] if transcription itself fails.
  Future<String?> stopAndTranscribe() async {
    if (!_recording) return null;

    final String? path = await _recorder.stop();
    _recording = false;
    if (path == null) return null;

    final File file = File(path);
    if (!await file.exists()) return null;

    try {
      return await AiService.instance.transcribe(file);
    } finally {
      await _deleteQuietly(file);
    }
  }

  /// Stops recording without transcribing (e.g. the user cancels mid-speech).
  Future<void> cancel() async {
    if (!_recording) return;
    final String? path = await _recorder.stop();
    _recording = false;
    if (path != null) {
      await _deleteQuietly(File(path));
    }
  }

  Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best-effort cleanup of a temp recording only.
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
