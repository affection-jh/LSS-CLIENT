import 'package:esc/firebase_options.dart';
import 'package:esc/screens/home_view.dart';
import 'package:esc/screens/onboarding_view.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '이순신랠리',
      home: FutureBuilder(
        future: AuthService.isSignedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data != null) {
            UserService().initializeUser(snapshot.data!);
            return HomeView();
          }
          return OnboardingView();
        },
      ),
    );
  }
}
