import 'package:esc/data/player.dart';
import 'package:esc/screens/view_switcher.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/appBar.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class BuildingView extends StatefulWidget {
  @override
  _BuildingViewState createState() => _BuildingViewState();
}

class _BuildingViewState extends State<BuildingView> {
  bool _isConnecting = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    // 빌드 완료 후 세션 생성 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _makeSession();
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _makeSession() async {
    final userService = UserService();
    Player? me = userService.getUser();

    if (me == null) {
      if (mounted) {
        AppUtil.showErrorSnackbar(context, message: "다시 로그인해주세요");
        Navigator.pop(context);
      }
      return;
    }

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isConnecting = true;
    });

    try {
      final gameManager = context.read<GameManager>();

      // 연결 타임아웃 설정 (10초)
      _timeoutTimer = Timer(Duration(seconds: 10), () {
        if (mounted && _isConnecting) {
          _handleConnectionFailure();
        }
      });

      // 웹소켓 연결
      await gameManager.connect();

      // 연결 상태 확인
      if (gameManager.wsState != WebSocketState.connected) {
        throw Exception('연결 실패');
      }

      // 세션 생성 요청
      gameManager.createSession(me.userId, me.name);

      int maxWait = 50;
      int waitCount = 0;

      while (gameManager.currentSession == null && waitCount < maxWait) {
        await Future.delayed(Duration(milliseconds: 100));
        waitCount++;
      }

      if (gameManager.currentSession == null) {
        _handleConnectionFailure();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ViewSwitcher()),
      );
      // 세션 생성 완료 후 ViewSwitcher로 이동
    } catch (e) {
      if (mounted) {
        _handleConnectionFailure();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
      _timeoutTimer?.cancel();
    }
  }

  void _handleConnectionFailure() {
    print('[MakingView] 연결 실패 처리 시작');

    // WebSocket 연결 정리
    final gameManager = context.read<GameManager>();
    if (gameManager.wsState != WebSocketState.disconnected) {
      gameManager.disconnect();
    }

    setState(() {
      _isConnecting = false;
    });

    AppUtil.showErrorSnackbar(context, message: "서버 연결에 실패했습니다.");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context, false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '장군님을 모셔오고 있어요',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '잠시만 기다려주세요',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                color: Colors.black,
                backgroundColor: Colors.grey.shade300,
                strokeWidth: 3,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
