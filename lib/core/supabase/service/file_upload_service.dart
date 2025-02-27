import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/database/db/database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Enum for file types
enum FileType {
  image,
  video,
  audio,
  file,
}

// File Upload Service
class FileUploadService {
  
  FileUploadService(this._supabaseClient, this._localDb);
  final SupabaseClient _supabaseClient;

  final LocalDatabase _localDb;
  
  // Get correct bucket name based on file type
  String _getBucketName(FileType type) {
    switch (type) {
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video';
      case FileType.audio:
        return 'audio';
      case FileType.file:
        return 'file';
    }
  }
  
  // Get correct message type for database
  String _getMessageType(FileType type) {
    switch (type) {
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video';
      case FileType.audio:
        return 'audio';
      case FileType.file:
        return 'file';
    }
  }
  
  // Upload file to Supabase storage
  Future<String?> uploadFileToSupabase(File file, FileType type, String chatId) async {
    try {
      final String bucketName = _getBucketName(type);
      final String fileName = '${const Uuid().v4()}${path.extension(file.path)}';
      final String filePath = '$chatId/$fileName';
      
      // Upload to Supabase storage
      final response = await _supabaseClient
          .storage
          .from(bucketName)
          .upload(filePath, file);
      
      // Get public URL
      final String publicUrl = _supabaseClient
          .storage
          .from(bucketName)
          .getPublicUrl(filePath);
          
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }
  
  // Save message with attachment to Supabase
  Future<String?> saveMessageWithAttachment({
    required String chatId,
    required String userId,
    required FileType fileType,
    required String attachmentUrl,
    required String attachmentName,
    String? content,
  }) async {
    try {
      final messageType = _getMessageType(fileType);
      
      // Insert into Supabase messages table
      final response = await _supabaseClient
          .from('messages')
          .insert({
            'chat_id': chatId,
            'user_id': userId,
            'content': content,
            'message_type': messageType,
            'attachment_url': attachmentUrl,
            'attachment_name': attachmentName,
            'is_read': false,
          })
          .select()
          .single();
      
      // Update last_message_at in chats table
      await _supabaseClient
          .from('chats')
          .update({'last_message_at': DateTime.now().toIso8601String()})
          .eq('id', chatId);
      
      // Save to local database
      await _saveMessageLocally(
        id: response['id'] as String,
        chatId: chatId,
        userId: userId,
        content: content,
        messageType: messageType,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
        createdAt: DateTime.parse(response['created_at'] as String),
        isRead: false,
      );
      
      return response['id'] as String;
    } catch (e) {
      debugPrint('Error saving message: $e');
      return null;
    }
  }
  
  // Save file locally and return local path
  Future<String> saveFileLocally(File file, FileType type, String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String typeFolder = _getBucketName(type);
      final Directory typeDir = Directory('${appDir.path}/$typeFolder');
      
      if (!await typeDir.exists()) {
        await typeDir.create(recursive: true);
      }
      
      final String localPath = '${typeDir.path}/$fileName';
      await file.copy(localPath);
      
      return localPath;
    } catch (e) {
      debugPrint('Error saving file locally: $e');
      rethrow;
    }
  }
  
  // Save message to local database
  Future<void> _saveMessageLocally({
    required String id,
    required String chatId,
    required String userId,
    required String messageType, required String attachmentUrl, required String attachmentName, required DateTime createdAt, required bool isRead, String? content,
  }) async {
    await _localDb.saveMessage(
      MessagesCompanion.insert(
        id: id,
        chatId: chatId,
        userId: userId,
        content: Value(content),
        messageType: messageType,
        attachmentUrl: Value(attachmentUrl),
        attachmentName: Value(attachmentName),
        createdAt: createdAt,
        updatedAt: createdAt,
        isRead: Value(isRead),
        isSynced: const Value(true),
      ),
    );
  }
  
  // Upload image from image picker
  Future<String?> uploadImage(XFile imageFile, String chatId, String userId, {String? caption}) async {
    final file = File(imageFile.path);
    final fileName = path.basename(imageFile.path);
    
    // Save locally first
    final localPath = await saveFileLocally(file, FileType.image, fileName);
    
    // Upload to Supabase
    final attachmentUrl = await uploadFileToSupabase(file, FileType.image, chatId);
    
    if (attachmentUrl != null) {
      // Save message with attachment
      final messageId = await saveMessageWithAttachment(
        chatId: chatId,
        userId: userId,
        fileType: FileType.image,
        attachmentUrl: attachmentUrl,
        attachmentName: fileName,
        content: caption,
      );
      
      return messageId;
    }
    
    return null;
  }
  
  // Upload video from file picker
  Future<String?> uploadVideo(File videoFile, String chatId, String userId, {String? caption}) async {
    final fileName = path.basename(videoFile.path);
    
    // Save locally first
    final localPath = await saveFileLocally(videoFile, FileType.video, fileName);
    
    // Upload to Supabase
    final attachmentUrl = await uploadFileToSupabase(videoFile, FileType.video, chatId);
    
    if (attachmentUrl != null) {
      // Save message with attachment
      final messageId = await saveMessageWithAttachment(
        chatId: chatId,
        userId: userId,
        fileType: FileType.video,
        attachmentUrl: attachmentUrl,
        attachmentName: fileName,
        content: caption,
      );
      
      return messageId;
    }
    
    return null;
  }
  
  // Upload audio from record package
  Future<String?> uploadAudio(String audioPath, String chatId, String userId) async {
    final file = File(audioPath);
    final fileName = path.basename(audioPath);
    
    // Save locally first
    final localPath = await saveFileLocally(file, FileType.audio, fileName);
    
    // Upload to Supabase
    final attachmentUrl = await uploadFileToSupabase(file, FileType.audio, chatId);
    
    if (attachmentUrl != null) {
      // Save message with attachment
      final messageId = await saveMessageWithAttachment(
        chatId: chatId,
        userId: userId,
        fileType: FileType.audio,
        attachmentUrl: attachmentUrl,
        attachmentName: fileName,
      );
      
      return messageId;
    }
    
    return null;
  }
  
  // Upload general file from file picker
  Future<String?> uploadFile(PlatformFile pickedFile, String chatId, String userId) async {
    final file = File(pickedFile.path!);
    final fileName = pickedFile.name;
    
    // Save locally first
    final localPath = await saveFileLocally(file, FileType.file, fileName);
    
    // Upload to Supabase
    final attachmentUrl = await uploadFileToSupabase(file, FileType.file, chatId);
    
    if (attachmentUrl != null) {
      // Save message with attachment
      final messageId = await saveMessageWithAttachment(
        chatId: chatId,
        userId: userId,
        fileType: FileType.file,
        attachmentUrl: attachmentUrl,
        attachmentName: fileName,
      );
      
      return messageId;
    }
    
    return null;
  }
  
  // Sync local unsynchronized files to Supabase
  Future<void> syncUnsyncedFiles() async {
    try {
      // Get all unsynced messages with attachments
      final unsyncedMessages = await _localDb.getUnsyncedMessagesWithAttachments();
      
      for (final message in unsyncedMessages) {
        if (message.attachmentUrl != null && message.attachmentUrl!.startsWith('file://')) {
          // This is a local file path that needs to be uploaded
          final file = File(message.attachmentUrl!.replaceFirst('file://', ''));
          
          if (await file.exists()) {
            // Determine file type
            FileType fileType;
            switch (message.messageType) {
              case 'image':
                fileType = FileType.image;
                break;
              case 'video':
                fileType = FileType.video;
                break;
              case 'audio':
                fileType = FileType.audio;
                break;
              default:
                fileType = FileType.file;
            }
            
            // Upload to Supabase
            final attachmentUrl = await uploadFileToSupabase(file, fileType, message.chatId);
            
            if (attachmentUrl != null) {
              // Update Supabase messages table
              await _supabaseClient
                  .from('messages')
                  .upsert({
                    'id': message.id,
                    'chat_id': message.chatId,
                    'user_id': message.userId,
                    'content': message.content,
                    'message_type': message.messageType,
                    'attachment_url': attachmentUrl,
                    'attachment_name': message.attachmentName,
                    'created_at': message.createdAt.toIso8601String(),
                    'updated_at': DateTime.now().toIso8601String(),
                    'is_read': message.isRead,
                  });
              
              // Update local message
              await _localDb.updateMessageAttachmentUrl(
                message.id,
                attachmentUrl,
                true, // set as synced
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error syncing unsynced files: $e');
    }
  }
}