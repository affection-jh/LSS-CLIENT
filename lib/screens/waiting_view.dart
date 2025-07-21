import 'dart:async';

import 'package:esc/screens/home_view.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/appBar.dart';
import 'package:esc/data/session.dart';
import 'package:esc/data/player.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:esc/utill/purse_coin.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WaitingView extends StatefulWidget {
  const WaitingView({super.key});

  @override
  State<WaitingView> createState() => _WaitingViewState();
}

class _WaitingViewState extends State<WaitingView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        // 세션이 없는 경우 로딩 화면
        if (gameManager.currentSession == null ||
            gameManager.currentSession!.players.isEmpty) {
          return HomeView();
        }

        final isPresident =
            gameManager.currentSession?.presidentId ==
            UserService().getUser()?.userId;

        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: buildAppBar(context, isPresident),
            body: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(gameManager),
                    SizedBox(height: 24),
                    _buildCurrentPlayerCard(gameManager),
                    SizedBox(height: 34),
                    _buildMemberSection(gameManager),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(GameManager gameManager) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTimeRemaining(
                    gameManager.currentSession?.gameEndTime ?? DateTime.now(),
                  ),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 255, 125, 125),
                  ),
                ),
                Text(
                  "시간이 끝나도 찾아와요!",
                  style: TextStyle(fontSize: 16, color: Color(0xFF6C757D)),
                ),
              ],
            ),
          ),
          Expanded(child: Image.asset('assets/sitting_cute_lee.png')),
        ],
      ),
    );
  }

  Widget _buildCurrentPlayerCard(GameManager gameManager) {
    final session = gameManager.currentSession;
    if (session == null) {
      return Container();
    }
    final currentPlayer = session.currentPlayer;
    if (currentPlayer == null) {
      return Container(
        child: Center(
          child: Text(
            '현재 플레이어 정보를 불러올 수 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Text(
              "${currentPlayer.name}의 동전은?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF495057),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(12),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 첫 번째 동전
                  Center(
                    child: session.firstCoinState == "null"
                        ? PulseQuestionMark(size: 120)
                        : session.firstCoinState == "head"
                        ? Image.asset(
                            'assets/coin_head.png',
                            width: 120,
                            height: 120,
                          )
                        : Image.asset(
                            'assets/coin_tail.png',
                            width: 120,
                            height: 120,
                          ),
                  ),

                  SizedBox(width: 24),
                  Center(
                    child: session.secondCoinState == "null"
                        ? PulseQuestionMark(size: 120)
                        : session.secondCoinState == "head"
                        ? Image.asset(
                            'assets/coin_head.png',
                            width: 120,
                            height: 120,
                          )
                        : Image.asset(
                            'assets/coin_tail.png',
                            width: 120,
                            height: 120,
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSection(GameManager gameManager) {
    final session = gameManager.currentSession;
    if (session == null) {
      return Container();
    }

    final myIndex =
        session.players.indexWhere(
          (player) => player.userId == UserService().getUser()?.userId,
        ) +
        1;
    final currentPlayerIndex = session.currentPlayerIndex + 1;
    final isClockWise = session.isClockWise;

    final memberCountBeforeMe = isClockWise
        ? (currentPlayerIndex - myIndex).abs()
        : (myIndex - currentPlayerIndex).abs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "내 차례까지 $memberCountBeforeMe명!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF495057),
          ),
        ),
        SizedBox(height: 12),
        _buildPlayerList(
          session,
          session.currentPlayer,
          gameManager.currentUserId,
        ),
      ],
    );
  }

  Widget _buildPlayerList(
    Session session,
    Player? currentPlayer,
    String? currentUserId,
  ) {
    final players = List<Player>.from(session.players);

    // 현재 턴인 플레이어를 최상단으로 정렬
    players.sort((a, b) {
      final aIsCurrent = a.userId == currentPlayer?.userId;
      final bIsCurrent = b.userId == currentPlayer?.userId;

      if (aIsCurrent && !bIsCurrent) return -1;
      if (!aIsCurrent && bIsCurrent) return 1;
      return 0;
    });

    return Container(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          final isCurrentPlayer = player.userId == currentPlayer?.userId;
          final isMe = player.userId == currentUserId;
          final isPresident = player.userId == session.presidentId;

          return _buildPlayerCard(player, isCurrentPlayer, isMe, isPresident);
        },
      ),
    );
  }

  Widget _buildPlayerCard(
    Player player,
    bool isCurrentPlayer,
    bool isMe,
    bool isPresident,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? const Color.fromARGB(255, 255, 249, 251) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: player.profileImageUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: player.profileImageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorPalette.primaryColor.withOpacity(0.3),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: ColorPalette.primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorPalette.primaryColor,
                            ),
                            child: Center(
                              child: Text(
                                player.name.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(255, 255, 180, 180),
                      ),
                      child: Center(
                        child: Text(
                          player.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 16),
          // 플레이어 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF495057),
                      ),
                    ),
                    Expanded(child: SizedBox(width: 8)),
                    if (isCurrentPlayer)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF007BFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "현재턴",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 210, 210, 210),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "대기중",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeRemaining(DateTime endTime) {
    final now = DateTime.now();
    final duration = endTime.difference(now);
    final totalSeconds = duration.inSeconds;

    if (totalSeconds <= 0) {
      return '00:00';
    }

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
