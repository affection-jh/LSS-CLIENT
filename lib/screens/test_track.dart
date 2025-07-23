import 'dart:async';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/appBar.dart';
import 'package:esc/utill/coin_spin.dart' show CoinSpinWidget;
import 'package:flutter/material.dart';

class TestTrack extends StatefulWidget {
  const TestTrack({super.key});

  @override
  State<TestTrack> createState() => _TestTrackState();
}

class _TestTrackState extends State<TestTrack> {
  String coin1 = "";
  String coin2 = "";
  bool buttonEnabled = false;
  final bool isLeesoonSin = false;
  Key coinSpinKey = UniqueKey();

  late DateTime _endTime;
  late Timer _timer;
  int _remainingSeconds = 120; // 2분 타이머 예시

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  void _resetTimer() {
    _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = _endTime.difference(now).inSeconds;
      if (diff <= 0) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        // 타이머가 끝나면 TestLeesoonSin 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TestLeesoonSin()),
        );
      } else {
        setState(() {
          _remainingSeconds = diff;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context, false, category: "개인 플레이 모드"),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              _buildHeader(),
              _buildCoinSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  _formatTime(_remainingSeconds),
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

  Widget _buildCoinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Text(
              '동전을 클릭해 멈추세요.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '행운을 빌어요 ^^',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Center(
              child: CoinSpinWidget(
                key: coinSpinKey,
                coinSize: MediaQuery.of(context).size.height * 0.15,
                coinSpacing: MediaQuery.of(context).size.height * 0.05,
                onCoin1Stopped: (result) {
                  coin1 = result;
                  if (coin1 == "head" && coin2 == "head") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TestLeesoonSin()),
                    );
                  }
                  if (coin1.isNotEmpty && coin2.isNotEmpty) {
                    setState(() {
                      buttonEnabled = true;
                    });
                  }
                },
                onCoin2Stopped: (result) {
                  coin2 = result;
                  if (coin1 == "head" && coin2 == "head") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TestLeesoonSin()),
                    );
                  }
                  if (coin1.isNotEmpty && coin2.isNotEmpty) {
                    setState(() {
                      buttonEnabled = true;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        buttonEnabled
            ? SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    coin1 = "";
                    coin2 = "";
                    buttonEnabled = false;
                    coinSpinKey = UniqueKey(); // key 변경!
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  '다음으로',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            )
            : SizedBox.shrink(),
        SizedBox(height: 20),
      ],
    );
  }
}

String _formatTime(int totalSeconds) {
  if (totalSeconds <= 0) return '00:00';
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class TestLeesoonSin extends StatefulWidget {
  const TestLeesoonSin({super.key});

  @override
  State<TestLeesoonSin> createState() => _TestLeesoonSinState();
}

class _TestLeesoonSinState extends State<TestLeesoonSin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context, false),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "${UserService().getUser()?.name} 장군님이 오셨어요!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: _buildLeeImage(
                          UserService().getUser()?.profileImageUrl ?? null,
                        ),
                      );
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 10,
                      top: 1,
                    ),
                    child: Material(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TestTrack(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            '계속하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeeImage(String? imageUrl) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 태블릿에서는 이미지 크기를 적당히 조정
        final imageSize = constraints.maxWidth * 1.2; // 모바일용 기존 크기
        final coinSize = imageSize * 0.32;
        final coinTop = imageSize * 0.008;
        final coinRight = imageSize * 0.21;

        return Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/lee.png',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: coinTop,
              right: coinRight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(coinSize / 2),
                child: SizedBox(
                  width: coinSize,
                  height: coinSize,
                  child: Center(
                    child:
                        imageUrl != null
                            ? Image.network(
                              imageUrl,
                              width: coinSize,
                              height: coinSize,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: coinSize,
                                  height: coinSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color.fromARGB(
                                      255,
                                      216,
                                      216,
                                      216,
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: coinSize,
                                  height: coinSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color.fromARGB(
                                      255,
                                      216,
                                      216,
                                      216,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.person,
                                      size: coinSize * 0.7,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              width: coinSize,
                              height: coinSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color.fromARGB(255, 216, 216, 216),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: coinSize * 0.7,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
