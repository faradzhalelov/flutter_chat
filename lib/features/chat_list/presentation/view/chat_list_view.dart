import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:flutter_chat/features/chat_list/components/create_chat_dialog.dart';
import 'package:flutter_chat/features/chat_list/presentation/components/chat_list_item.dart';
import 'package:flutter_chat/features/profile/presentation/view/profile_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatListView extends ConsumerWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatListStreamProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        title: Text(
          'Чаты',
          style: AppTextStyles.largeTitle.copyWith(
            color: AppColors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icomoon.person,
              color: AppColors.black,
            ),
            onPressed: () => context.push('/${ProfileView.routePath}'),
            tooltip: 'Перейти в профиль',
          ),
          IconButton(
            icon: const Icon(
              Icomoon.outRight,
              color: AppColors.black,
            ),
            onPressed: () async => ref.read(authStateProvider.notifier).signOut(context),
            tooltip: 'Выйти из аккаунта',
          ),
        ],
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 60,
      ),
      floatingActionButton: IconButton(
        icon: const Icon(
          Icomoon.plusS,
          color: AppColors.black,
        ),
        onPressed: () => context.showCreateChatDialog(),
        tooltip: 'Создать чат',
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.searchBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Поиск',
                  hintStyle: AppTextStyles.medium.copyWith(
                    color: AppColors.gray,
                  ),
                  prefixIcon: const Icon(
                    Icomoon.searchS,
                    color: AppColors.gray,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          const Divider(
            color: AppColors.divider,
          ),
          // Chat list
          Expanded(
            child: chatsAsync.when(
              data: (chats) {
                if (chats.isEmpty) {
                  return const Center(
                    child: Text('Нет диалогов'),
                  );
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ChatListItem(
                      chat: chat,
                      onTap: () => context.go('/chat/${chat.id}'),
                      onDismissed: (_) {
                        ref.read(chatRepositoryProvider).deleteChat(chat.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Чат с ${chat.user.username} удален'),
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'Отмена',
                              onPressed: () {
                                // Undo delete (would require more complex logic)
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icomoon.error,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки диалогов',
                        style: AppTextStyles.medium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(chatListStreamProvider),
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
