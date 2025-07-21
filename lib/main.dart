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
      home: FutureBuilder(
        future: initializeUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == null) {
            return OnboardingView();
          }

          if (snapshot.data?.name.isEmpty ?? true) {
            return ProfileSettingView();
          } else {
            return HomeView();
          }
        },
      ),
    );
  }
}
