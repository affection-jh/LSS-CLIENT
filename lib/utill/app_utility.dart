import 'package:flutter/material.dart';

class ColorPalette {
  static Color primaryColor = const Color.fromARGB(255, 255, 180, 180);
  static Color secondaryColor = const Color.fromARGB(255, 32, 32, 32);
}

class AppUtil {
  static Future<bool?> ShowExitDiaglog(
    BuildContext context,
    bool isPresident,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          '정말 나가시겠습니까?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isPresident ? '방장이 나가면 게임이 종료돼요.' : '남은 사람들은 진행이 어려울 수도 있어요.',
          style: TextStyle(fontSize: 15, color: Color(0xFF6C757D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '확인',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  static void showErrorSnackbar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color backgroundColor = const Color.fromARGB(255, 255, 70, 70),
    Color textColor = const Color.fromARGB(255, 255, 238, 238),
    SnackBarAction? action,
  }) {
    try {
      // context가 여전히 유효한지 확인
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            duration: duration,
            backgroundColor: backgroundColor,
            action: action,

            behavior: SnackBarBehavior.floating,
            dismissDirection: DismissDirection.up, // 위로 밀어서 닫기
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom:
                  MediaQuery.of(context).size.height - getTopPadding(context),
            ),
          ),
        );
      }
    } catch (e) {
      // context가 이미 dispose된 경우 무시
      print('SnackBar 표시 실패: $e');
    }
  }

  static double getTopPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // 베젤이 있는 기기 판단 (더 정확한 방법)
    bool hasBezel = false;

    // iPhone SE 시리즈 판단
    if (screenHeight <= 667 && screenWidth <= 375) {
      hasBezel = true;
    }

    // iPhone 8 이하 판단
    if (screenHeight <= 667 && screenWidth <= 375 && devicePixelRatio <= 2.0) {
      hasBezel = true;
    }

    // 베젤이 있는 기기: 더 큰 패딩
    if (hasBezel) {
      return 80.0;
    }

    // 노치/다이나믹 아일랜드 기기: 적은 패딩
    return 150.0;
  }
}
