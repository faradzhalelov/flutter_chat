import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_chat/core/supabase/repository/supabase_repository.dart';
import 'package:flutter_chat/core/supabase/service/supabase_service.dart';
import 'package:flutter_chat/features/chat/data/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Provider to fetch all users except the current user
final allUsersProvider =
    AutoDisposeFutureProvider<List<UserModel>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];

  try {
    final response = await supabase
        .from('users')
        .select('id, username, email, created_at, last_seen, is_online')
        .neq('id', currentUser.id);
    final usersInBase =
        response.map((userData) => UserModel.fromSupabase(userData)).toList();
    final createdChats = ref.watch(chatListStreamProvider).asData?.value ?? [];
    return usersInBase
        .where(
            (u) => !createdChats.map((e) => e.user.id).toList().contains(u.id))
        .toList();
  } catch (e) {
    log('Error fetching users: $e');
    return [];
  }
});

class CreateChatDialog extends ConsumerStatefulWidget {
  const CreateChatDialog({super.key});

  @override
  ConsumerState<CreateChatDialog> createState() => _CreateChatDialogState();
}

class _CreateChatDialogState extends ConsumerState<CreateChatDialog> {
  UserModel? _selectedUser;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return AlertDialog(
      title: Text(
        'Создать чат',
        style: AppTextStyles.medium.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: usersAsync.when(
        data: (users) => SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                selectedTileColor: AppColors.gray,
                title: Text(
                  user.username,
                  style: AppTextStyles.medium.copyWith(
                    color: AppColors.black,
                  ),
                ),
                subtitle: Text(user.email),
                leading: user.avatarUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(user.avatarUrl!),
                      )
                    : const CircleAvatar(
                        child: Icon(Icomoon.person),
                      ),
                selected: _selectedUser?.id == user.id,
                onTap: () {
                  setState(() {
                    _selectedUser = user;
                  });
                },
              );
            },
          ),
        ),
        loading: () => const SizedBox(
          width: 50,
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Center(
          child: Text(
            'Ошибка загрузки пользователей: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _selectedUser == null
              ? null
              : () async {
                  try {
                    // Create a new chat with the selected user
                    await SupabaseChatRepository()
                        .createChat(_selectedUser!.id);

                    
                  } catch (e) {
                    log('CreateChatDialog error: $e');
                    // Show error if chat creation fails
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Не удалось создать чат: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    await Future.delayed(Durations.long1, () {
                      if (context.mounted) {
                        context.pop();
                      }
                    });
                  }
                },
          child: const Text('Создать чат'),
        ),
      ],
    );
  }
}

// Extension method to show create chat dialog
extension CreateChatDialogExtension on BuildContext {
  Future<void> showCreateChatDialog() async => showDialog(
        context: this,
        builder: (context) => const CreateChatDialog(),
      );
}
