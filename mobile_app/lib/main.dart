import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/recommendation_provider.dart';
import 'providers/session_provider.dart';
import 'screens/shell_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final session = SessionProvider();
  await session.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionProvider>.value(value: session),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
      ],
      child: const BnplAdvisorApp(),
    ),
  );
}

class BnplAdvisorApp extends StatelessWidget {
  const BnplAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SME Advisor',
      theme: AppTheme.light(),
      home: const ShellScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
