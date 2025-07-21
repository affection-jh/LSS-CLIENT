import 'package:esc/data/session.dart';
import 'package:esc/screens/home_view.dart';
import 'package:esc/service/manage_service.dart';
import 'package:esc/service/user_service.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:esc/utill/coin_spin.dart';
import 'package:provider/provider.dart';

class MyTurnView extends StatefulWidget {
  const MyTurnView({super.key});

  @override
  State<MyTurnView> createState() => _MyTurnViewState();
}

class _MyTurnViewState extends State<MyTurnView> {
  bool myTurnCompleted = false;
  bool isLoading = false;
  bool coin1Completed = false;
  bool coin2Completed = false;

  @override
  void dispose() {
    super.dispose();
    coin1Completed = false;
    coin2Completed = false;
  }

  @override
  Widget build(BuildContext context) {
    final gameManager = context.read<GameManager>();
    final Session? currentSession = gameManager.currentSession;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.05),
                  Text(
                    '동전을 클릭해 멈추세요.',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '행운을 빌어요 ^^',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: CoinSpinWidget(
                coinSpacing: MediaQuery.of(context).size.height * 0.05,
                onCoin1Stopped: (result) {
                  gameManager.setCoinState("first", result.toString());

                  coin1Completed = true;

                  // 두 동전이 모두 완료되었는지 확인
                  if (coin1Completed && coin2Completed) {
                    setState(() {
                      myTurnCompleted = true;
                    });
                  }
                },
                onCoin2Stopped: (result) {
                  gameManager.setCoinState("second", result.toString());
                  coin2Completed = true;
                  // 두 동전이 모두 완료되었는지 확인
                  if (coin1Completed && coin2Completed) {
                    setState(() {
                      myTurnCompleted = true;
                    });
                  }
                },
              ),
            ),
            Spacer(flex: 2),
            myTurnCompleted
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isLoading) return;
                          setState(() => isLoading = true);
                          gameManager.nextTurn();
                          Future.delayed(Duration(seconds: 5), () {
                            if (mounted && isLoading) {
                              setState(() {
                                isLoading = false;
                              });
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      '네트워크 상태를 확인해주세요.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: Text(
                                      '홈화면으로 나갈까요?',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF6C757D),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          '취소',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeView(),
                                              ),
                                              (route) => false,
                                            ),
                                        child: Text(
                                          '확인',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
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
                        child: isLoading
                            ? CircularProgressIndicator(
                                strokeWidth: 1,
                                color: Colors.white,
                              )
                            : Text(
                                '다음으로',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  )
                : SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
