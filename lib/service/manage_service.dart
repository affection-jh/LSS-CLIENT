import 'package:esc/data/player.dart';
import 'package:flutter/foundation.dart';

import 'package:esc/data/session.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum WebSocketState { disconnected, connecting, connected, error }

class GameManager extends ChangeNotifier {
  // WebSocket 연결 관련
  WebSocket? webSocket;
  WebSocketState wsState = WebSocketState.disconnected;

  // 게임 상태 관련
  Session? currentSession;
  String? currentUserId;
  bool? isGamePlaying;

  // 에러 상태
  String? errorCode;
  String? errorMessage;

  // WebSocket 연결
  Future<void> connect() async {
    print('[GameManager] WebSocket 연결 시도');

    if (wsState == WebSocketState.connecting) {
      print('[GameManager] 이미 연결 시도중 - 연결 시도 중단');
      return;
    }

    if (wsState == WebSocketState.connected) {
      print('[GameManager] 이미 연결됨 - 연결 시도 중단');
      return;
    }

    try {
      print('[GameManager] 연결 상태를 connecting으로 변경');
      wsState = WebSocketState.connecting;

      webSocket = await WebSocket.connect('ws://158.179.174.166:8080/ws');

      print('[GameManager] WebSocket 연결 성공!');
      wsState = WebSocketState.connected;

      webSocket!.listen(_onMessageReceived);
    } catch (e) {
      print('[GameManager] 연결 실패: $e');
      wsState = WebSocketState.disconnected;
      errorMessage = '연결에 실패했습니다: $e';
    }
  }

  // WebSocket 메시지 수신
  void _onMessageReceived(dynamic data) {
    try {
      final message = json.decode(data);
      print('[GameManager] 메시지 수신: ${message.toString()}');
      final messageType = message['type'];

      switch (messageType) {
        case 'ok':
          _handleGameStateUpdatedMessage(message);
          break;
        case 'error':
          _handleErrorMessage(message);
          break;
        default:
          print('[GameManager] 알 수 없는 메시지 타입: $messageType');
          break;
      }
    } catch (e) {
      errorMessage = '메시지 파싱 오류: $e';
    }
  }

  // 게임 상태 업데이트 메시지 처리
  void _handleGameStateUpdatedMessage(Map<String, dynamic> message) {
    try {
      print(
        '[GameManager] 서버에서 받은 동전 상태: firstCoinState=${message['firstCoinState']}, secondCoinState=${message['secondCoinState']}',
      );
      currentSession = Session.fromJson(message);
      print(
        '[GameManager] 파싱 후 동전 상태: firstCoinState=${currentSession?.firstCoinState}, secondCoinState=${currentSession?.secondCoinState}',
      );
      notifyListeners();
      print('[GameManager] 세션 데이터 파싱 완료');
    } catch (e) {
      print('[GameManager] 세션 데이터 파싱 오류: $e');
    }
  }

  // 에러 메시지 처리
  void _handleErrorMessage(Map<String, dynamic> message) {
    // 에러 정보 설정
    errorCode = message['errorCode'];
    errorMessage = message['message'];
    notifyListeners();
  }

  // 메시지 전송
  void sendRequest(String action, Map<String, dynamic> data) {
    if (!_checkConnectionBeforeRequest()) return;

    final message = {'action': action, 'data': data};
    print('[GameManager] 전송할 메시지: ${json.encode(message)}');

    try {
      webSocket!.add(json.encode(message));
      print('[GameManager] 메시지 전송 성공');
    } catch (e) {
      print('[GameManager] 메시지 전송 실패: $e');
      errorMessage = '메시지 전송 실패: $e';
    }
  }

  // 연결 상태 확인 후 요청 전송
  bool _checkConnectionBeforeRequest() {
    if (wsState != WebSocketState.connected) {
      errorMessage = 'WebSocket이 연결되지 않았습니다.';
      return false;
    }
    return true;
  }

  // 게임 액션들
  void createSession(String userId, String name) {
    print('[GameManager] 세션 생성 요청: userId=$userId, name=$name');
    if (!_checkConnectionBeforeRequest()) return;

    currentUserId = userId;
    sendRequest('create-session', {'userId': userId, 'name': name});
  }

  void joinSession(String entryCode, Player player) {
    print(
      '[GameManager] 세션 참여 요청: entryCode=$entryCode, player=${player.name}',
    );
    if (!_checkConnectionBeforeRequest()) return;

    currentUserId = player.userId;
    sendRequest('join-session', {
      'entryCode': entryCode,
      'userId': player.userId,
      'name': player.name,
    });
  }

  void setCoinState(String coinType, String state) {
    print('[GameManager] 동전 상태 설정: coinType=$coinType, state=$state');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('coin-action', {
        'sessionId': currentSession!.sessionId,
        'coinType': coinType,
        'state': state,
        'userId': currentUserId,
      });
    } else {
      print('[GameManager] 세션 정보 부족 - 동전 상태 설정 실패');
    }
  }

  void nextTurn() {
    print('[GameManager] 다음 턴 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('next-turn', {
        'sessionId': currentSession!.sessionId,
        'userId': currentUserId,
      });
    } else {
      print('[GameManager] 세션 정보 부족 - 다음 턴 요청 실패');
    }
  }

  void skipTurn() {
    print('[GameManager] 턴 스킵 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('skip-turn', {
        'userId': currentUserId,
        'sessionId': currentSession!.sessionId,
      });
    } else {
      print('[GameManager] 세션 정보 부족 - 턴 스킵 요청 실패');
    }
  }

  void registerOrder() {
    print('[GameManager] 주문 등록 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('register-order', {
        'userId': currentUserId,
        'sessionId': currentSession!.sessionId,
      });
    }
  }

  void startOrdering() {
    print('[GameManager] 게임 시작 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('start-ordering', {
        'sessionId': currentSession!.sessionId,
        'userId': currentUserId,
      });
    } else {
      print('[GameManager] 세션 정보 부족 - 게임 시작 요청 실패');
    }
  }

  void startPlaying() {
    print('[GameManager] 게임 플레이 시작 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('start-playing', {
        'sessionId': currentSession!.sessionId,
        'userId': currentUserId,
      });
    } else {
      print('[GameManager] 세션 정보 부족 - 게임 플레이 시작 요청 실패');
    }
  }

  void continueLeeSoonSin() {
    print('[GameManager] 이순신 계속 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('continue-lee-soon-sin', {
        'sessionId': currentSession!.sessionId,
        'userId': currentUserId,
      });
    } else {
      print('[GameManager] 세션 정보 부족 - 이순신 계속 요청 실패');
    }
  }

  void leaveSession() {
    print('[GameManager] 세션 나가기 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('leave-session', {
        'userId': currentUserId,
        'sessionId': currentSession!.sessionId,
      });
      _exitGame();
    } else {
      print('[GameManager] 세션 정보 부족 - 세션 나가기 요청 실패');
    }
  }

  void deleteSession() {
    print('[GameManager] 세션 삭제 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('delete-session', {
        'userId': currentUserId,
        'sessionId': currentSession!.sessionId,
      });
      _exitGame();
    } else {
      print('[GameManager] 세션 정보 부족 - 세션 삭제 요청 실패');
    }
  }

  void getGameState() {
    print('[GameManager] 게임 상태 요청');
    if (!_checkConnectionBeforeRequest()) return;

    if (currentSession?.sessionId != null && currentUserId != null) {
      sendRequest('get-game-state', {
        'userId': currentUserId,
        'sessionId': currentSession!.sessionId,
      });
    } else {
      print('[GameManager] 세션 정보 부족 - 게임 상태 요청 실패');
    }
  }

  // 게임 종료 처리
  void _exitGame() {
    currentSession = null;
    currentUserId = null;
    isGamePlaying = false;
    print('[GameManager] 게임 상태 초기화 완료');
  }

  // 리소스 정리
  void dispose() {
    disconnect();
    super.dispose();
  }

  // 연결 해제
  void disconnect() {
    webSocket?.close();
    _exitGame();
    clearError();
    wsState = WebSocketState.disconnected;
    print('[GameManager] 연결 해제 완료');
  }

  // 에러 초기화
  void clearError() {
    print('[GameManager] 에러 초기화');
    errorCode = null;
    errorMessage = null;
  }
}
