// lib/presentation/chat/viewmodel/chat_viewmodel.dart
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat/core/supabase/service/providers/file_upload_service_provider.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/features/chat/data/models/atachment_type.dart';
import 'package:flutter_chat/features/chat/data/repositories/provider/chat_repository_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_view_model.g.dart';

/// ViewModel for the chat screen using the abstract ChatRepository
@riverpod
class ChatViewModel extends _$ChatViewModel {
  final _audioRecorder = AudioRecorder();
  String? _recordingPath;

  @override
  FutureOr<void> build(String chatId) {
    // Clean up resources when the provider is disposed
    ref.onDispose(() {
      _audioRecorder.dispose();
    });
  }

  /// Send a text message
  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    state = const AsyncValue.loading();
    try {
      await ref.read(chatRepositoryProvider).sendTextMessage(chatId, text);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Pick and send an image
  Future<void> sendImageMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    state = const AsyncValue.loading();
    try {
      final userId = supabase.auth.currentUser!.id;
      //upload to bucket
      final String? attachementUrl = await ref
          .read(fileUploadServiceProvider)
          .uploadFile(pickedFile, MessageType.image, chatId, userId);
      //save message in db
      //save message in supabase
      await ref.read(chatRepositoryProvider).sendFileMessage(
          chatId, MessageType.image, attachementUrl, pickedFile.name);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      log('sendImageMessage:$e $st');
      state = AsyncValue.error(e, st);
    }
  }

  /// Pick and send a video
  Future<void> sendVideoMessage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
        source: ImageSource.gallery, maxDuration: const Duration(minutes: 1));

    if (pickedFile == null) return;

    state = const AsyncValue.loading();

    try {
      final userId = supabase.auth.currentUser!.id;
      //upload to bucket
      final String? attachementUrl = await ref
          .read(fileUploadServiceProvider)
          .uploadFile(pickedFile, MessageType.video, chatId, userId);
  
      //save message in db
      //save message in supabase
      await ref.read(chatRepositoryProvider).sendFileMessage(
            chatId,
            MessageType.video,
            attachementUrl,
            pickedFile.name,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Pick and send a file
  Future<void> sendFileMessage() async {
    final result = await FilePicker.platform.pickFiles();
    final pickedFile = result?.xFiles.first;
    if (pickedFile == null) return;

    state = const AsyncValue.loading();

    try {
      final userId = supabase.auth.currentUser!.id;
      //upload to bucket
      final String? attachementUrl = await ref
          .read(fileUploadServiceProvider)
          .uploadFile(pickedFile, MessageType.file, chatId, userId);

      //save message in db
      //save message in supabase
      await ref.read(chatRepositoryProvider).sendFileMessage(
            chatId,
            MessageType.file,
            attachementUrl,
            pickedFile.name,
          );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Start recording audio
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
          log('startRecording error: _recordingPath null');
        }
      }
    } catch (e) {
      _recordingPath = null;
      rethrow;
    }
  }

  /// Stop recording and send audio message
  Future<void> stopRecordingAndSend() async {
    if (_recordingPath == null) return;

    state = const AsyncValue.loading();

    try {
      await _audioRecorder.stop();
      final pickedFile = XFile(_recordingPath!);
      
      final userId = supabase.auth.currentUser!.id;
      //upload to bucket
      final String? attachementUrl = await ref
          .read(fileUploadServiceProvider)
          .uploadFile(pickedFile, MessageType.audio, chatId, userId);
     
      //save message in db
      //save message in supabase
      await ref.read(chatRepositoryProvider).sendFileMessage(
            chatId,
            MessageType.audio,
            attachementUrl,
            pickedFile.name,
          );

      _recordingPath = null;
      state = const AsyncValue.data(null);
    } catch (e, st) {
      _recordingPath = null;
      state = AsyncValue.error(e, st);
    }
  }

  /// Cancel recording
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

  /// Mark messages as read
  Future<void> markMessagesAsRead() async {
    try {
      await ref.read(chatRepositoryProvider).markMessagesAsRead(chatId);
    } catch (e) {
      // Handle error silently
    }
  }
}

