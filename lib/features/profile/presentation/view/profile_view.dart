import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_chat/features/auth/presentation/view/components/auth_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});
  static const String routePath = 'profile';

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  File? _avatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userProfile = await ref.read(userProfileProvider.future);

      setState(() {
        _usernameController.text = (userProfile['username'] as String?) ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки профиля: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarFile = File(pickedFile.path);
      });
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите имя пользователя';
    }

    if (value.length < 3) {
      return 'Имя должно содержать минимум 3 символа';
    }

    return null;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authStateProvider.notifier).updateProfile(
            username: _usernameController.text.trim(),
            avatarFile: _avatarFile,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления профиля: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authStateProvider.notifier).signOut(context);
      // Router will handle navigation
    } catch (e) {
      log('_signOut error:$e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка выхода из аккаунта: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBackground,
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icomoon.outRight),
            onPressed: _isLoading ? null : _signOut,
            tooltip: 'Выйти',
          ),
        ],
      ),
      body: userProfileAsync.when(
        data: (userProfile) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.myMessageBubble,
                        backgroundImage: _avatarFile != null
                            ? FileImage(_avatarFile!)
                            : userProfile['avatar_url'] != null
                                ? NetworkImage(
                                    userProfile['avatar_url'] as String)
                                : null,
                        child: _avatarFile == null &&
                                userProfile['avatar_url'] == null
                            ? Text(
                                _getInitials(
                                    userProfile['username'] as String? ?? ''),
                                style: AppTextStyles.largeTitle.copyWith(color: Colors.white),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.myMessageBubble,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Email display
                Text(
                  userProfile['email'] as String? ?? 'No email',
                  style: AppTextStyles.medium.copyWith(color: Colors.grey),
                 
                ),
                const SizedBox(height: 32),

                // Username field
                AuthTextField(
                  controller: _usernameController,
                  labelText: 'Имя пользователя',
                  hintText: 'Введите ваше имя',
                  prefixIcon: Icons.person_outline,
                  validator: _validateUsername,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),

                // Update button
                AuthButton(
                  text: 'Обновить профиль',
                  onPressed: _updateProfile,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки профиля:$error stacktrace:$stackTrace',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.small.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(userProfileProvider),
                  child: const Text('Попробовать снова'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return parts.take(2).map((part) => part[0].toUpperCase()).join();
    } else if (name.length > 1) {
      return name.substring(0, 2).toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}
