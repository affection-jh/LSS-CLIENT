import 'package:esc/data/player.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/utill/appBar.dart';

import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PendingView extends StatefulWidget {
  const PendingView({Key? key}) : super(key: key);

  @override
  _PendingViewState createState() => _PendingViewState();
}

class _PendingViewState extends State<PendingView> {
  bool _isCopied = false;
  bool _isStartLoading = false;
  void _handleStartGame(GameManager gameManager) async {
    // 이미 로딩 중이면 중복 요청 방지
    if (_isStartLoading) return;

    final currentUser = UserService().getUser();
    final isCurrentUserPresident =
        currentUser != null &&
        gameManager.currentSession!.presidentId == currentUser.userId;

    if (!isCurrentUserPresident) {
      AppUtil.showErrorSnackbar(context, message: "방장만 게임을 시작할 수 있어요.");
      return;
    }

    // 플레이어 수 확인 (최소 2명)
    if (gameManager.currentSession!.players.length < 2) {
      AppUtil.showErrorSnackbar(context, message: "최소 2명이 필요해요.");
      return;
    }

    setState(() {
      _isStartLoading = true;
    });

    // 게임 시작 요청
    gameManager.startOrdering();

    // 3초 후 로딩 상태 해제
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _isStartLoading = false;
        });
        AppUtil.showErrorSnackbar(context, message: "네트워크 연결을 확인해주세요.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        // 세션이 없는 경우 로딩 화면
        if (gameManager.currentSession == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('게임 정보를 불러오는 중...'),
                ],
              ),
            ),
          );
        }

        gameManager.totalJoinCount = gameManager.currentSession!.players.length;

        final isPresident =
            gameManager.currentSession!.presidentId ==
            UserService().getUser()?.userId;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context, isPresident),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '장군님이 도착하셨어요.',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '입장코드를 공유해볼까요?',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildCodeView(gameManager),
                            const SizedBox(height: 30),

                            Text(
                              '${gameManager.currentSession!.players.length}명이 입장했어요.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 10,
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.8,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemCount: gameManager.currentSession!.players.length,
                          itemBuilder: (context, index) => _buildPendingMember(
                            gameManager.currentSession!.players[index],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildStartButton(gameManager),
              SizedBox(height: 10), // 하단에 고정
            ],
          ),
        );
      },
    );
  }

  Widget _buildCodeView(GameManager gameManager) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              _copyToClipboard(gameManager.currentSession!.entryCode);
            },

            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    gameManager.currentSession!.entryCode,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.black,
                    ),
                  ),
                  Icon(
                    _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(String entryCode) {
    Clipboard.setData(ClipboardData(text: entryCode));
    setState(() => _isCopied = true);
  }

  Widget _buildPendingMember(Player user) {
    final gameManager = context.read<GameManager>();
    final isPresident = gameManager.currentSession?.presidentId == user.userId;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: user.userId == UserService().getUser()?.userId
              ? const Color.fromARGB(255, 255, 240, 240)
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 30
                          : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isPresident)
                    Text(
                      '방장',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 65, 65, 65),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(GameManager gameManager) {
    // 현재 사용자가 방장인지 확인
    final currentUser = UserService().getUser();
    final isCurrentUserPresident =
        currentUser != null &&
        gameManager.currentSession!.presidentId == currentUser.userId;

    if (isCurrentUserPresident) {
      // 방장인 경우 시작 버튼 표시
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: SizedBox(
          height: 60,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Material(
              color: ColorPalette.secondaryColor,
              child: InkWell(
                onTap: () async {
                  _handleStartGame(gameManager);
                },
                child: Center(
                  child: _isStartLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.white,
                        )
                      : Text(
                          '시작하기',
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
    } else {
      // 방장이 아닌 경우 대기 메시지
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              '방장이 게임을 시작할 때까지 기다려주세요',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
  }
}
