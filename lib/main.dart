import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // sqflite não funciona na web - pula inicialização
  if (!kIsWeb) {
    await DatabaseHelper.initDatabase();
  }
  runApp(
    const ProviderScope(
      child: EcoShareApp(),
    ),
  );
}

class EcoShareApp extends StatelessWidget {
  const EcoShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EcoShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
