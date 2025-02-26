// lib/features/auth/presentation/view/login_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/core/utils/validators/validators.dart';
import 'package:flutter_chat/features/auth/presentation/view/components/auth_widgets.dart';
import 'package:flutter_chat/features/auth/presentation/view/components/forgot_password_dialog.dart';
import 'package:flutter_chat/features/auth/presentation/view_model/login_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});
  static const String routePath = 'login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the ViewModel
    final viewModel = ref.watch(loginViewModelProvider.notifier);
    final state = ref.watch(loginViewModelProvider);
    
    // Show error snackbar if error exists
    _showErrorSnackbarIfNeeded(context, state.errorMessage, viewModel.resetError);
    
    return Scaffold(
      backgroundColor: Colors.white,
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
                    title: 'Вход в аккаунт',
                    subtitle: 'Добро пожаловать обратно!',
                  ),
                  const SizedBox(height: 40),
                  
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
                    hintText: 'Введите ваш пароль',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !state.isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icomoon.notView
                            : Icomoon.view,
                        color: Colors.grey,
                      ),
                      onPressed: !state.isLoading ? viewModel.togglePasswordVisibility : null,
                    ),
                    validator: Validators.validatePassword,
                    enabled: !state.isLoading,
                  ),
                  
                  // Forgot password link
                  _buildForgotPasswordLink(context, state.isLoading, viewModel),
                  const SizedBox(height: 24),
                  
                  // Login button
                  AuthButton(
                    text: 'Войти',
                    onPressed: state.isLoading ? null : viewModel.login,
                    isLoading: state.isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Register link
                  _buildRegisterLink(context, state.isLoading),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildForgotPasswordLink(
    BuildContext context, 
    bool isLoading,
    LoginViewModel viewModel,
  ) => Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isLoading 
            ? null 
            : () async => _showForgotPasswordDialog(context, viewModel),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: const Text(
          'Забыли пароль?',
          style: TextStyle(
            color: AppColors.myMessageBubble,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  
  Widget _buildRegisterLink(BuildContext context, bool isLoading) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Нет аккаунта? ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: isLoading ? null : () => context.go('/register'),
          child: const Text(
            'Зарегистрироваться',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.myMessageBubble,
            ),
          ),
        ),
      ],
    );
  
  Future<void> _showForgotPasswordDialog(BuildContext context, LoginViewModel viewModel) async => showDialog(
      context: context,
      builder: (context) => ForgotPasswordDialog(
        onSubmit: viewModel.resetPassword,
        onSuccess: viewModel.clearPasswordResetStatus,
      ),
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
