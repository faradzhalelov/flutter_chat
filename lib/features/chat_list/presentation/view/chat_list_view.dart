// features/chat_list/presentation/views/chat_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_chat/features/chat/data/models/chat.dart';
import 'package:flutter_chat/features/chat_list/components/create_chat_dialog.dart';
import 'package:flutter_chat/features/chat_list/presentation/components/chat_list_item.dart';
import 'package:flutter_chat/features/chat_list/presentation/view_model/chat_list_view_model.dart';
import 'package:flutter_chat/features/profile/presentation/view/profile_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ChatListView extends HookConsumerWidget {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the chat list view model
    final chatListState = ref.watch(chatListViewModelProvider);
    final viewModel = ref.watch(chatListViewModelProvider.notifier);

    // Using hooks for search functionality
    final searchController = useTextEditingController();
    final searchFocusNode = useFocusNode();

    // Create a state for the search query that will trigger rebuilds
    final searchQuery = useState('');
    final isSearching = useState(false);

    // Listen to search controller changes for visual indicator
    useEffect(
      () {
        void listener() {
          isSearching.value = searchController.text.isNotEmpty;
          // Update the searchQuery state to trigger the useMemoized hook
          searchQuery.value = searchController.text;
        }

        searchController.addListener(listener);

        return () {
          searchController.removeListener(listener);
        };
      },
      [searchController],
    );

    // Handle search functionality with memoization to avoid unnecessary rebuilds
    // Now depends on searchQuery.value instead of searchController.text
    final filteredChats = useMemoized(
      () {
        if (!chatListState.hasValue || searchQuery.value.isEmpty) {
          return chatListState;
        }

        final query = searchQuery.value.toLowerCase();

        // Filter by both username and last message content
        final filteredList = chatListState.value!.where((chat) {
          final usernameMatch =
              chat.user.username.toLowerCase().contains(query);
          final lastMessageMatch =
              chat.lastMessage?.text?.toLowerCase().contains(query) ?? false;

          return usernameMatch || lastMessageMatch;
        }).toList();

        return AsyncValue.data(filteredList);
      },
      [chatListState, searchQuery.value], // Depend on searchQuery.value
    );

    // Refresh effect - ensures the chat list is up to date when component mounts
    useEffect(
      () {
        // Force a refresh when the component first loads
        // This helps with the issue of chats not showing immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.refresh();
        });

        return null;
      },
      [],
    );

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: _buildAppBar(context, ref),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        onPressed: () async => _showCreateChatDialog(context),
        tooltip: 'Создать чат',
        child: const Icon(
          Icomoon.plusS,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(searchController, searchFocusNode, isSearching),
          const Divider(color: AppColors.divider),
          _buildChatList(context, filteredChats, viewModel),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) =>
      AppBar(
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
            onPressed: () async =>
                ref.read(authStateProvider.notifier).signOut(context),
            tooltip: 'Выйти из аккаунта',
          ),
        ],
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 60,
      );

  Widget _buildSearchBar(
    TextEditingController controller,
    FocusNode focusNode,
    ValueNotifier<bool> isSearching,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.searchBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: AppTextStyles.medium,
            decoration: InputDecoration(
              filled: false,
              hintText: 'Поиск',
              hintStyle: AppTextStyles.medium.copyWith(
                color: AppColors.gray,
              ),
              prefixIcon: const Icon(
                Icomoon.searchS,
                color: AppColors.gray,
                size: 24,
              ),
              suffixIcon: isSearching.value
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.gray),
                      onPressed: () {
                        controller.clear();
                        focusNode.unfocus();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 6,
              ),
              border: InputBorder.none,
            ),
            textInputAction: TextInputAction.search,
          ),
        ),
      );

  Widget _buildChatList(
    BuildContext context,
    AsyncValue<List<ChatModel>> chatListState,
    ChatListViewModel viewModel,
  ) =>
      Expanded(
        child: chatListState.when(
          data: (chats) {
            if (chats.isEmpty) {
              return _buildEmptyState();
            }
            chats.sort((a, b) {
              final aTime = a.lastMessageTime;
              final bTime = a.lastMessageTime;
              if (aTime != null && bTime != null) {
                return aTime.compareTo(bTime);
              } else if (aTime != null && bTime == null) {
                return 1;
              } else if (aTime == null && bTime != null) {
                return -1;
              } else {
                return b.createdAt.compareTo(a.createdAt);
              }
            });
            return _buildChatListItems(context, chats, viewModel);
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildErrorState(context, error, viewModel),
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icomoon.message,
              size: 64,
              color: AppColors.gray,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет активных диалогов',
              style: AppTextStyles.medium.copyWith(
                color: AppColors.gray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Начните общение, нажав на + внизу экрана',
              style: AppTextStyles.small.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildChatListItems(
    BuildContext context,
    List<ChatModel> chats,
    ChatListViewModel viewModel,
  ) =>
      RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return ChatListItem(
              chat: chat,
              onTap: () => context.go('/chat/${chat.id}'),
              onDismissed: (_) =>
                  _handleChatDismissed(context, chat, viewModel),
            );
          },
        ),
      );

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    ChatListViewModel viewModel,
  ) =>
      Center(
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
                style: AppTextStyles.small,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );

  void _handleChatDismissed(
    BuildContext context,
    ChatModel chat,
    ChatListViewModel viewModel,
  ) {
    viewModel.deleteChat(chat.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Чат с ${chat.user.username} удален'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showCreateChatDialog(
    BuildContext context,
  ) async =>  showDialog(
      context: context,
      builder: (dialogContext) => const CreateChatDialog(),
    );
}
