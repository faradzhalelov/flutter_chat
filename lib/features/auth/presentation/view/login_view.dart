// lib/presentation/auth/view/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_chat/features/auth/presentation/view/components/auth_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});
  static const String routePath = 'login';

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Введите корректный email';
    }
    
    return null;
  }
  
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }
    
    if (value.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    
    return null;
  }
  
  Future<void> _login() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Get form values
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    try {
      // Attempt to sign in
      await ref.read(authStateProvider.notifier).signIn(
        email: email,
        password: password,
      );
      
      // No need to navigate, the router will handle it
    } catch (e) {
      // Show error message if sign-in fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка входа: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
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
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Введите ваш email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  // Password field
                  AuthTextField(
                    controller: _passwordController,
                    labelText: 'Пароль',
                    hintText: 'Введите ваш пароль',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: _validatePassword,
                    enabled: !isLoading,
                  ),
                  
                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading 
                          ? null 
                          : () async => showDialog(
                                context: context,
                                builder: (context) => _buildForgotPasswordDialog(context),
                              ),
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
                  ),
                  const SizedBox(height: 24),
                  
                  // Login button
                  AuthButton(
                    text: 'Войти',
                    onPressed: isLoading ? null : _login,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Register link
                  Row(
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
                        onPressed: isLoading
                            ? null
                            : () => context.go('/register'),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    return AlertDialog(
      title: const Text('Сброс пароля'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите ваш email для получения инструкций по сбросу пароля',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            AuthTextField(
              controller: emailController,
              labelText: 'Email',
              hintText: 'Введите ваш email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              // Close dialog
              Navigator.of(context).pop();
              
              try {
                // Send password reset email
                await ref.read(authStateProvider.notifier).resetPassword(
                  emailController.text.trim(),
                );
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Инструкции по сбросу пароля отправлены на ваш email'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Show error message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          child: const Text('Отправить'),
        ),
      ],
    );
  }
}