import 'package:flutter_chat/features/chat/data/models/message.dart';
import 'package:flutter_chat/features/chat/data/repositories/provider/chat_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messages_pod.g.dart';

@riverpod
class MessagesPod extends _$MessagesPod {
  @override
  FutureOr<List<MessageModel>> build(String chatId) async {
    final chatRepository = ref.watch(chatRepositoryProvider);
    final List<MessageModel> messages = <MessageModel>[];
    final messagesForChat = await chatRepository.getMessagesForChat(chatId);
    messages.addAll(messagesForChat);
    chatRepository.subscribeToMessages(chatId).listen((message) {
      messages.add(message);
    });
    return messages;
  }
}
