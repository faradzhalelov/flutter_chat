import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/app/database/db/message_type.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// File Upload Service
class FileUploadService {
  const FileUploadService();

  // Upload file to Supabase storage
  Future<String?> uploadFileToSupabase(
      File file, MessageType type, String chatId,) async {
    try {
      final String bucketName = type.name;
      final String userId = supabase.auth.currentUser?.id ?? 'anonymous';
      final String fileName =
          '${const Uuid().v4()}${path.extension(file.path)}';
      // Include userId in the path to help with RLS policies
      final String filePath = '$userId/$chatId/$fileName';

      // Upload to Supabase storage
      await supabase.storage.from(bucketName).upload(
            filePath,
            file,
            fileOptions: const FileOptions(
              // cacheControl: '3600',
              upsert: true,
            ),
          );

      // Get public URL
      final String publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      // Throw a more descriptive error for debugging
      throw Exception('Storage upload failed: $e');
    }
  }

  // Save file locally and return local path
  Future<String> saveFileLocally(
      File file, MessageType type, String fileName) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String typeFolder = type.name;
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

  // Upload file
  Future< String?> uploadFile(
      XFile xFile, MessageType type, String chatId, String userId,
      {String? caption,}) async {
    final file = File(xFile.path);
    // Upload to Supabase
    final attachmentUrl = await uploadFileToSupabase(file, type, chatId);
    return attachmentUrl;
  }
}
