import 'package:esc/data/player.dart';
import 'package:esc/data/session.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/appBar.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderRegisterView extends StatefulWidget {
  const OrderRegisterView({super.key});

  @override
  State<OrderRegisterView> createState() => _OrderRegisterViewState();
}

class _OrderRegisterViewState extends State<OrderRegisterView> {
  List<Player> _orderedPlayers = [];
  late ScrollController _scrollController;
  final List<bool> _animationStates = [];
  bool _isLoading = false;
  int _prevLength = 0;
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _orderedPlayers.clear();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        final Session? currentSession = gameManager.currentSession;
        final isPresident =
            currentSession!.presidentId == UserService().getUser()?.userId;

        final myUserId = UserService().getUser()?.userId;
        if (myUserId == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: buildAppBar(context, isPresident),
            body: Center(child: Text('사용자 정보를 불러올 수 없습니다.')),
          );
        }

        // 서버에서 실시간으로 받은 플레이어 정보로 UI 업데이트
        if (_orderedPlayers.length != currentSession.players.length) {
          _orderedPlayers = List<Player>.from(currentSession.players);
        }

        // 현재 사용자가 순서에 등록되었는지 서버 응답으로 확인
        final isMyOrderRegistered = currentSession.players.any(
          (player) => player.userId == myUserId,
        );

        // 애니메이션 상태 길이 맞추기
        while (_animationStates.length < _orderedPlayers.length) {
          _animationStates.add(false);
        }
        while (_animationStates.length > _orderedPlayers.length) {
          _animationStates.removeLast();
        }

        // 자동 스크롤: 새 플레이어가 추가됐을 때만
        if (_prevLength < _orderedPlayers.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
            // 애니메이션 시작
            Future.delayed(Duration(milliseconds: 100), () {
              setState(() {
                _animationStates[_orderedPlayers.length - 1] = true;
              });
            });
          });
        }
        _prevLength = _orderedPlayers.length;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context, isPresident),
          body: Stack(
            children: [
              // 스크롤 가능한 메인 콘텐츠
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 스크롤 가능한 헤더
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '아무나 먼저, 자리 순서대로',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '버튼을 눌러 차례를 등록해주세요.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '장군님이 순서를 기억할거에요. ${currentSession.players.length}/${gameManager.totalJoinCount}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // 리스트 영역
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildOrderCell(index),
                        childCount: _orderedPlayers.length,
                      ),
                    ),
                  ),

                  // 하단 여백 (버튼 공간 확보)
                  SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),

              // 하단 고정 버튼
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: (isPresident && isMyOrderRegistered)
                    ? _buildPresidentButton()
                    : _buildOrderButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: _entered ? Colors.grey.shade300 : Colors.black,
          child: InkWell(
            onTap: () async {
              if (_isLoading || _entered) {
                return;
              }

              if (UserService().getUser() == null) {
                return;
              }

              setState(() => _isLoading = true);
              context.read<GameManager>().registerOrder();
              await Future.delayed(Duration(milliseconds: 100));
              setState(() => _isLoading = false);
              setState(() => _entered = true);
            },
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1,
                    )
                  : Text(
                      _entered ? '등록 완료' : '내 차례 등록하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresidentButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.blue,
          child: InkWell(
            onTap: () async {
              if (_isLoading) {
                return;
              }

              final gameManager = context.read<GameManager>();

              setState(() => _isLoading = true);

              if (gameManager.currentSession!.players.length < 2) {
                AppUtil.showErrorSnackbar(
                  context,
                  message: "플레이어는 최소 2명 이상이어야 해요.",
                );
                setState(() => _isLoading = false);
                return;
              }
              gameManager.startPlaying();
              Future.delayed(Duration(seconds: 10), () {
                if (mounted && _isLoading) {
                  setState(() {
                    _isLoading = false;
                  });
                  AppUtil.showErrorSnackbar(
                    context,
                    message: "네트워크 상태를 확인해주세요.",
                  );
                }
              });
              return;
            },
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.white,
                    )
                  : Text(
                      '시작하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCell(int index) {
    return AnimatedOpacity(
      opacity: _animationStates[index] ? 1.0 : 0.0,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        transform: Matrix4.translationValues(
          _animationStates[index] ? 0 : -50,
          0,
          0,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _orderedPlayers[index].name,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: MediaQuery.of(context).size.width > 600
                          ? 25
                          : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 세로 연결선 (마지막 항목이 아닌 경우)
            if (index < _orderedPlayers.length - 1)
              Container(width: 1, height: 10, color: Colors.grey.shade400),
            if (index == _orderedPlayers.length - 1) SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
