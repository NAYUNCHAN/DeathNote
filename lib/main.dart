import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IncidentNoteApp());
}

class IncidentNoteApp extends StatelessWidget {
  const IncidentNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '기록노트',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF607D8B),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
