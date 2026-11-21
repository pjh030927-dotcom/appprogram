import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/experience_screen.dart';
import 'screens/resume_detail_screen.dart';
import 'providers/resume_provider.dart';
import 'providers/experience_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 새로고침(F5) 시 어떤 URL로 진입해도 데이터가 바로 로드되도록 사전 초기화
  final resumeProvider = ResumeProvider();
  final experienceProvider = ExperienceProvider();
  await Future.wait([
    resumeProvider.loadResumes(),
    experienceProvider.loadExperiences(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: resumeProvider),
        ChangeNotifierProvider.value(value: experienceProvider),
      ],
      child: const CoverLetterApp(),
    ),
  );
}

final GoRouter _appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/specs',
      builder: (context, state) => const ExperienceScreen(),
    ),
    GoRoute(
      path: '/resume/:id',
      builder: (context, state) {
        final resumeId = state.pathParameters['id'] ?? '';
        return ResumeDetailScreen(resumeId: resumeId);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('페이지를 찾을 수 없습니다')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('요청하신 주소를 찾을 수 없습니다.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('대시보드로 돌아가기'),
          ),
        ],
      ),
    ),
  ),
);

class CoverLetterApp extends StatelessWidget {
  const CoverLetterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);
    const bgLightBlue = Color(0xFFF4F7FC);

    return MaterialApp.router(
      title: '커리어핏 AI - 맞춤형 자소서 관리',
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgLightBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: const Color(0xFF1E88E5),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD0D7DE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD0D7DE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
