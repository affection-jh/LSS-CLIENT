import 'package:esc/data/player.dart';
import 'package:esc/service/error_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/screens/view_switcher.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class GameJoiningView extends StatefulWidget {
  const GameJoiningView({super.key});

  @override
  State<GameJoiningView> createState() => _GameEnteringViewState();
}

class _GameEnteringViewState extends State<GameJoiningView>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isError = false; // 에러 상태 추가
  bool _isEntering = false;
  String _errorMessage = '';
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _controller.text.length == 6;
      if (_isError) {
        _isError = false; // 텍스트가 변경되면 에러 상태 해제
      }
    });
  }

  void _showError(String msg) {
    setState(() {
      _isError = true;
      _errorMessage = msg;
      _isButtonEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '방장이 알려준',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    '입장 코드를 입력해볼까요?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Transform.translate(
                offset: Offset(0, 0),
                child: PinCodeTextField(
                  autoFocus: true,
                  controller: _controller,
                  length: 6,
                  obscureText: false,
                  cursorColor: _isError ? Colors.red : Colors.black,
                  animationType: AnimationType.fade,
                  animationDuration: Duration(milliseconds: 300),
                  onChanged: (value) {
                    _onTextChanged();
                  },
                  appContext: context,
                  textStyle: TextStyle(
                    fontSize: 24,
                    color: _isError ? Colors.red : Colors.black,
                  ),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 60,
                    fieldWidth: 50,
                    activeColor: _isError ? Colors.red : Colors.black,
                    selectedColor: _isError ? Colors.red : Colors.black,
                    inactiveColor: _isError ? Colors.red.shade300 : Colors.grey,
                    activeFillColor: Colors.transparent,
                    selectedFillColor: Colors.transparent,
                    inactiveFillColor: Colors.transparent,
                  ),
                ),
              ),
            ),
            // 에러 메시지
            if (_isError)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 2,
                ),
                child: AnimatedOpacity(
                  opacity: _isError ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            Expanded(child: SizedBox()),

            _buildEnterButton(
              _isError
                  ? Colors.grey.shade300
                  : (_isButtonEnabled
                        ? ColorPalette.secondaryColor
                        : Colors.grey.shade300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterButton(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: color,
          child: InkWell(
            onTap: () async {
              if (_isButtonEnabled && !_isEntering) {
                Player? me = UserService().getUser();

                if (me == null) {
                  _showError("로그인이 필요해요.");
                  return;
                }

                setState(() {
                  _isEntering = true;
                });

                try {
                  final gameManager = context.read<GameManager>();

                  // 연결 타임아웃 설정 (10초)
                  _timeoutTimer = Timer(Duration(seconds: 10), () {
                    if (mounted && _isEntering) {
                      _handleConnectionFailure();
                    }
                  });

                  // 웹소켓 연결
                  await gameManager.connect();

                  // 입장 요청
                  String code = _controller.text;
                  gameManager.joinSession(code, me);
                  await Future.delayed(Duration(milliseconds: 300));

                  if (gameManager.errorCode != null) {
                    _showError(
                      ErrorHandler.getErrorMessage(gameManager.errorCode!),
                    );
                    gameManager.clearError();
                    return;
                  }
                  // ViewSwitcher로 이동
                  else if (gameManager.currentSession != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ViewSwitcher()),
                    );
                    return;
                  }
                } catch (e) {
                  if (mounted) {
                    _handleConnectionFailure();
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isEntering = false;
                    });
                  }
                  _timeoutTimer?.cancel();
                }
              }
            },
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: Center(
                child: _isEntering
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        '입장하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleConnectionFailure() {
    // WebSocket 연결 정리
    final gameManager = context.read<GameManager>();
    if (gameManager.wsState != WebSocketState.disconnected) {
      gameManager.disconnect();
    }

    setState(() {
      _isEntering = false;
    });

    AppUtil.showErrorSnackbar(context, message: "서버 연결에 실패했어요ㅠ.");
    Navigator.pop(context);
  }
}
