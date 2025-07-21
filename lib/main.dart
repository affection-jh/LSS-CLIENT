import 'package:esc/data/player.dart';
import 'package:esc/firebase_options.dart';
import 'package:esc/screens/home_view.dart';
import 'package:esc/screens/onboarding_view.dart';
import 'package:esc/screens/profile_setting_view.dart';
import 'package:esc/service/auth_service.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameManager())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Player?> initializeUser() async {
    String? userId = await AuthService.isSignedIn();
    if (userId != null) {
      await UserService().initializeUser(userId);
      return UserService().getUser();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이순신랠리',
      home: FutureBuilder<Player?>(
        future: initializeUser(),
        builder: (context, snapshot) {
          // 로딩 중
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  color: const Color.fromARGB(255, 255, 143, 143),
                  strokeWidth: 2,
                ),
              ),
            );
          }

          // 에러 발생
          if (snapshot.hasError) {
            return OnboardingView();
          }

          final user = snapshot.data;

          // 로그인되지 않은 상태 (user == null)
          if (user == null) {
            return OnboardingView();
          }

          // 로그인은 되었지만 프로필 설정이 안된 상태
          if (user.name.isEmpty) {
            return ProfileSettingView(callFromWhere: 'main');
          }

          // 모든 설정 완료 상태
          return HomeView();
        },
      ),
    );
  }
}
