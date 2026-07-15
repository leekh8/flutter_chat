import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/signIn_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 플랫폼별 설정을 명시적으로 전달 — 인자 없이 호출하면 네이티브 설정 파일이 있는
  // Android/iOS만 초기화되고 웹·데스크톱에서는 실패한다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
