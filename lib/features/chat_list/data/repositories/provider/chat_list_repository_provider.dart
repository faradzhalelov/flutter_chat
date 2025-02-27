
import 'package:flutter_chat/features/chat_list/data/repositories/chat_list_repository.dart';
import 'package:flutter_chat/features/chat_list/data/repositories/chat_list_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_list_repository_provider.g.dart';

@riverpod
ChatListRepository chatListRepository(Ref ref) => ChatListRepositoryImpl();