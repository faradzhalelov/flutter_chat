// lib/features/auth/presentation/view/register_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/core/utils/validators/validators.dart';
import 'package:flutter_chat/features/auth/presentation/view/components/auth_widgets.dart';
import 'package:flutter_chat/features/auth/presentation/view_model/register_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends ConsumerWidget {
  const RegisterView({super.key});
  static const String routePath = 'register';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the ViewModel
    final viewModel = ref.watch(registerViewModelProvider.notifier);
    final state = ref.watch(registerViewModelProvider);
    
    // Show error snackbar if error exists
    _showErrorSnackbarIfNeeded(context, state.errorMessage, viewModel.resetError);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icomoon.arrowLeft, color: Colors.black),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: viewModel.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with app logo and title
                  const AuthHeader(
                    title: 'Создать аккаунт',
                    subtitle: 'Начните общаться прямо сейчас',
                  ),
                  const SizedBox(height: 32),
                  
                  // Username field
                  AuthTextField(
                    controller: viewModel.usernameController,
                    labelText: 'Имя пользователя',
                    hintText: 'Введите ваше имя',
                    prefixIcon: Icomoon.person,
                    validator: Validators.validateUsername,
                    enabled: !state.isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field
                  AuthTextField(
                    controller: viewModel.emailController,
                    labelText: 'Email',
                    hintText: 'Введите ваш email',
                    prefixIcon: Icomoon.mail,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    enabled: !state.isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  AuthTextField(
                    controller: viewModel.passwordController,
                    labelText: 'Пароль',
                    hintText: 'Введите пароль',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !state.isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icomoon.notView
                            : Icomoon.view,
                        color: Colors.grey,
                      ),
                      onPressed: !state.isLoading 
                          ? viewModel.togglePasswordVisibility 
                          : null,
                    ),
                    validator: Validators.validatePassword,
                    enabled: !state.isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm password field
                  AuthTextField(
                    controller: viewModel.confirmPasswordController,
                    labelText: 'Подтверждение пароля',
                    hintText: 'Повторите пароль',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !state.isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isConfirmPasswordVisible
                            ? Icomoon.notView
                            : Icomoon.view,
                        color: Colors.grey,
                      ),
                      onPressed: !state.isLoading 
                          ? viewModel.toggleConfirmPasswordVisibility 
                          : null,
                    ),
                    validator: viewModel.validateConfirmPassword,
                    enabled: !state.isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Register button
                  AuthButton(
                    text: 'Зарегистрироваться',
                    onPressed: state.isLoading ? null : () async => viewModel.register(context),
                    isLoading: state.isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Login link
                  _buildLoginLink(context, state.isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoginLink(BuildContext context, bool isLoading) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Уже есть аккаунт? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : () => context.go('/login'),
          child: const Text(
            'Войти',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.myMessageBubble,
            ),
          ),
        ),
      ],
    );
  
  void _showErrorSnackbarIfNeeded(
    BuildContext context, 
    String? errorMessage,
    VoidCallback resetError,
  ) {
    if (errorMessage != null) {
      // Use post-frame callback to avoid showing snackbar during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'ОК',
              textColor: Colors.white,
              onPressed: resetError,
            ),
          ),
        );
        
        // Reset error after showing snackbar
        resetError();
      });
    }
  }
}
