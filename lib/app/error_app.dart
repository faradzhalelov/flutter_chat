import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat/app/theme/icons.dart';
import 'package:flutter_chat/app/theme/text_styles.dart';

class ErrorApp extends StatelessWidget {
  const ErrorApp({required this.e, super.key});
  final Object e;

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icomoon.error,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                   Text(
                    'Ошибка инициализации приложения',
                    style: AppTextStyles.boldTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    e.toString(),
                    style: AppTextStyles.medium,

                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Restart app (this is a simple solution, not ideal)
                      SystemNavigator.pop();
                    },
                    child: const Text('Перезапустить приложение'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
