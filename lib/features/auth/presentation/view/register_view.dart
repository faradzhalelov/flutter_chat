// lib/presentation/auth/view/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_chat/app/theme/colors.dart';
import 'package:flutter_chat/core/auth/service/auth_service.dart';
import 'package:flutter_chat/features/auth/presentation/view/components/auth_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});
    static const String routePath = 'register';


  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
  
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Подтвердите пароль';
    }
    
    if (value != _passwordController.text) {
      return 'Пароли не совпадают';
    }
    
    return null;
  }
  
  Future<void> _register() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Get form values
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    try {
      // Attempt to sign up
      await ref.read(authStateProvider.notifier).signUp(
        email: email,
        password: password,
        username: username,
      );
      
      // No need to navigate, the router will handle it
    } catch (e) {
      // Show error message if sign-up fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка регистрации: $e'),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/login'),
        ),
      ),
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
                    title: 'Создать аккаунт',
                    subtitle: 'Начните общаться прямо сейчас',
                  ),
                  const SizedBox(height: 32),
                  
                  // Username field
                  AuthTextField(
                    controller: _usernameController,
                    labelText: 'Имя пользователя',
                    hintText: 'Введите ваше имя',
                    prefixIcon: Icons.person_outline,
                    validator: _validateUsername,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  
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
                    hintText: 'Введите пароль',
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
                  const SizedBox(height: 16),
                  
                  // Confirm password field
                  AuthTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Подтверждение пароля',
                    hintText: 'Повторите пароль',
                    prefixIcon: Icons.lock_outline,
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: _validateConfirmPassword,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Register button
                  AuthButton(
                    text: 'Зарегистрироваться',
                    onPressed: isLoading ? null : _register,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  
                  // Login link
                  Row(
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
                        onPressed: isLoading
                            ? null
                            : () => context.go('/login'),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
