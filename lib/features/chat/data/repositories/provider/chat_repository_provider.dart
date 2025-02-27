

import 'package:flutter_chat/features/chat/data/repositories/chat_repository.dart';
import 'package:flutter_chat/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_repository_provider.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) => ChatRepositoryImpl();
