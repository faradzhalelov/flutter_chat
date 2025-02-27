
import 'package:flutter_chat/core/supabase/service/file_upload_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_upload_service_provider.g.dart';

@riverpod
FileUploadService fileUploadService(Ref ref) => const FileUploadService();
