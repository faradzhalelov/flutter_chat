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
    final isSearching = useState(false);
    
    // Handle search functionality with memoization to avoid unnecessary rebuilds
    final filteredChats = useMemoized(() {
      if (!chatListState.hasValue || searchController.text.isEmpty) {
        return chatListState;
      }
      
      final query = searchController.text.toLowerCase();
      
      // Filter by both username and last message content
      final filteredList = chatListState.value!.where((chat) {
        final usernameMatch = chat.user.username.toLowerCase().contains(query);
        final lastMessageMatch = chat.lastMessage?.text?.toLowerCase().contains(query) ?? false;
        
        return usernameMatch || lastMessageMatch;
      }).toList();
      
      return AsyncValue.data(filteredList);
    }, [chatListState, searchController.text],);
    
    // Listen to search controller changes
    useEffect(() {
      void listener() {
        isSearching.value = searchController.text.isNotEmpty;
      }
      
      searchController.addListener(listener);
      
      return () {
        searchController.removeListener(listener);
      };
    }, [searchController],);

    // Refresh effect - ensures the chat list is up to date when component mounts
    useEffect(() {
      // Force a refresh when the component first loads
      // This helps with the issue of chats not showing immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.refresh();
      });
      
      return null;
    }, [],);

    return Scaffold(
      backgroundColor: Colors.white,
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
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider),
          _buildChatList(context, filteredChats, viewModel),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) => AppBar(
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
    );

  Widget _buildSearchBar(
    TextEditingController controller,
    FocusNode focusNode,
    ValueNotifier<bool> isSearching,
  ) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.searchBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Поиск диалогов',
            hintStyle: AppTextStyles.medium.copyWith(
              color: AppColors.gray,
            ),
            prefixIcon: const Icon(
              Icomoon.searchS,
              color: AppColors.gray,
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
              vertical: 12,
              horizontal: 8,
            ),
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: (_) {}, // Empty callback to ensure the state updates
        ),
      ),
    );

  Widget _buildChatList(
    BuildContext context, 
    AsyncValue<List<ChatModel>> chatListState,
    ChatListViewModel viewModel,
  ) => Expanded(
      child: chatListState.when(
        data: (chats) {
          if (chats.isEmpty) {
            return _buildEmptyState();
          }
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
  ) => RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      child: ListView.builder(
        itemCount: chats.length,
        
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ChatListItem(
            chat: chat,
            onTap: () => context.go('/chat/${chat.id}'),
            onDismissed: (_) => _handleChatDismissed(context, chat, viewModel),
          );
        },
      ),
    );

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    ChatListViewModel viewModel,
  ) => Center(
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
        action: SnackBarAction(
          label: 'Отмена',
          onPressed: () {
            // Refresh to restore all chats (simulating undo)
            viewModel.refresh();
          },
        ),
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