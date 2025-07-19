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
              bottom: MediaQuery.of(context).size.height - 150,
            ),
          ),
        );
      }
    } catch (e) {
      // context가 이미 dispose된 경우 무시
      print('SnackBar 표시 실패: $e');
    }
  }
}
