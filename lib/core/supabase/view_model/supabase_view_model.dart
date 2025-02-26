import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'supabase_view_model.g.dart';

@riverpod
class SupabaseChatViewModel extends _$SupabaseChatViewModel {
  late final SupabaseChatRepository _repository;
  final _audioRecorder = AudioRecorder();
  String? _recordingPath;

  @override
  FutureOr<void> build(String chatId) {
    _repository = ref.watch(supabaseChatRepositoryProvider);

    // Clean up resources when the provider is disposed
    ref.onDispose(() {
      _audioRecorder.dispose();
    });
  }

  // Send text message
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    state = const AsyncValue.loading();

    try {
      await _repository.sendTextMessage(chatId, text);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Send image message
  Future<void> sendImageMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    state = const AsyncValue.loading();

    try {
      final file = File(pickedFile.path);
      await _repository.sendImageMessage(chatId, file);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Send video message
  Future<void> sendVideoMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) return;

    state = const AsyncValue.loading();

    try {
      final file = File(pickedFile.path);
      await _repository.sendVideoMessage(chatId, file);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Send file message
  Future<void> sendFileMessage() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.single.path == null) return;

    state = const AsyncValue.loading();

    try {
      final file = File(result.files.single.path!);
      await _repository.sendFileMessage(chatId, file);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Start recording audio
  Future<void> startRecording() async {
    try {
      // Check permissions
      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        _recordingPath =
            '${tempDir.path}/audio_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

        if (_recordingPath != null) {
          await _audioRecorder.start(
            const RecordConfig(),
            path: _recordingPath!,
          );
        } else {
          log('_recordingPath null');
        }
      }
    } catch (e) {
      _recordingPath = null;
      rethrow;
    }
  }

  // Stop recording and send audio message
  Future<void> stopRecordingAndSend() async {
    if (_recordingPath == null) return;

    state = const AsyncValue.loading();

    try {
      await _audioRecorder.stop();

      final file = File(_recordingPath!);
      if (await file.exists()) {
        await _repository.sendAudioMessage(chatId, file);
      }

      _recordingPath = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _recordingPath = null;
      state = AsyncValue.error(e, st);
    }
  }

  // Cancel recording
  Future<void> cancelRecording() async {
    if (_recordingPath == null) return;

    try {
      await _audioRecorder.stop();

      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }

      _recordingPath = null;
    } catch (e) {
      _recordingPath = null;
      rethrow;
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead() async {
    try {
      await _repository.markMessagesAsRead(chatId);
    } catch (e) {
      // Handle error silently
    }
  }
}
