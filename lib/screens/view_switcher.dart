import 'package:esc/screens/home_view.dart';
import 'package:esc/screens/leesoonsin_view.dart';
import 'package:esc/screens/myturn_view.dart';
import 'package:esc/screens/order_register_view.dart';
import 'package:esc/screens/pending_view.dart';
import 'package:esc/screens/waiting_view.dart';
import 'package:esc/service/error_handler.dart';
import 'package:esc/utill/app_utility.dart';
import 'package:flutter/material.dart';
import 'package:esc/service/manage_service.dart';
import 'package:provider/provider.dart';

class ViewSwitcher extends StatefulWidget {
  const ViewSwitcher({super.key});

  @override
  State<ViewSwitcher> createState() => _ViewSwitcherState();
}

class _ViewSwitcherState extends State<ViewSwitcher> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameManager>(
      builder: (context, gameManager, child) {
        // 에러가 있는 경우 에러 처리
        if (gameManager.errorCode != null && !_hasNavigated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasNavigated) {
              AppUtil.showErrorSnackbar(
                context,
                message: ErrorHandler.getErrorMessage(gameManager.errorCode!),
              );
              if (ErrorHandler.isGameEndingError(gameManager.errorCode!)) {
                _hasNavigated = true;
                gameManager.disconnect();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeView()),
                  (route) => false,
                );
              } else {
                gameManager.clearError();
              }
            }
          });
        }

        if (gameManager.currentSession == null) {
          return HomeView();
        }

        // 게임 상태에 따라 화면 전환
        switch (gameManager.currentSession!.gameState) {
          case 'WAITING_ROOM':
            return PendingView();
          case 'ORDER_REGISTER':
            return OrderRegisterView();
          case 'GAME_PLAYING':
            return gameManager.currentSession!.isMyTurn
                ? MyTurnView()
                : WaitingView();
          case 'LEE_SOON_SIN':
            return LeeSoonSinView();
          default:
            return HomeView();
        }
      },
    );
  }
}
