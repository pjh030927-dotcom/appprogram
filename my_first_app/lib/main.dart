import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const CoverLetterApp());
}

class CoverLetterApp extends StatelessWidget {
  const CoverLetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '맞춤형 자소서 AI 수정 도움 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
