import 'package:esc/data/player.dart';
import 'package:esc/screens/home_view.dart';
import 'package:esc/screens/profile_setting_view.dart';
import 'package:esc/service/auth_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

final List<String> imagePaths = [
  'assets/cute_lee.png',
  'assets/sitting_cute_lee.png',
];

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // 이미지 PageView
            const SizedBox(height: 40),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, idx) {
                  return Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.black, // 배경색
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          imagePaths[idx],
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // 페이지 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imagePaths.length,
                (idx) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  width: _currentPage == idx ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == idx ? Colors.black : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            // 고정 텍스트
            const SizedBox(height: 40),
            const Text(
              '이순신게임,',
              style: TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '간편하게 로그인하고 시작하세요',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            const Spacer(),
            _isLoading ? _buildProgressCircle() : _buildLoginButtons(),
            const SizedBox(height: 20),
            _buildPrivacyPolicyLink(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    return Column(
      children: [
        CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
        SizedBox(height: 85),
      ],
    );
  }

  Widget _buildLoginButtons() {
    return Column(
      children: [
        _buildGoogleLoginButton(),
        const SizedBox(height: 10),
        _buildAppleLoginButton(),
      ],
    );
  }

  Widget _buildAppleLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.black,
        shadowColor: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            User? user = await AuthService.signInwithApple();
            if (user != null) {
              await UserService().initializeUser(user.uid);
              Player? player = UserService().getUser();
              if (player?.name.isEmpty ?? true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileSettingView()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeView()),
                );
              }
              _isLoading = false;
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/apple_logo.png', width: 28, height: 28),
                const SizedBox(width: 14),
                Text(
                  'Apple로 시작하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.white,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(16),
        elevation: 10,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            User? user = await AuthService.signInWithGoogle();
            if (user != null) {
              await UserService().initializeUser(user.uid);
              Player? player = UserService().getUser();
              if (player?.name.isEmpty ?? true) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileSettingView()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeView()),
                );
              }
              _isLoading = false;
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/google_logo.png', width: 28, height: 28),
                const SizedBox(width: 14),
                Text(
                  'Google로 시작하기',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyLink() {
    return GestureDetector(
      onTap: () {
        showCustomBottomSheet(
          context: context,

          content: _buildPrivacyContent(),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.privacy_tip_outlined, size: 12, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            '개인정보 처리방침',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '개인정보 처리방침',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '이순신랠리는 개인정보를 안전하게 보호합니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '수집하는 정보:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• 닉네임\n• 프로필 이미지\n• 게임 참여 기록',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '이용 목적:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• 게임 서비스 제공\n• 사용자 식별\n• 게임 기록 관리',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '보관 기간:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• 서비스 이용 기간 동안 보관\n• 회원 탈퇴 시 즉시 삭제',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
