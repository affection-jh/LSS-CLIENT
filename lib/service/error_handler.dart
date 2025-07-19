class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  static String getErrorMessage(String errorType) {
    switch (errorType) {
      // �� 매우 자주 발생 (높음) - 네트워크/연결 관련
      case 'CONNECTION_LOST':
        return '연결이 끊어졌어요.';
      case 'NETWORK_TIMEOUT':
        return '네트워크 시간 초과입니다.';

      // �� 매우 자주 발생 (높음) - 게임 진행 중 자동 발생
      case 'PLAYER_DISCONNECTED':
        return '다른 플레이어의 연결이 끊어졌어요.';
      case 'TURN_SKIPPED':
        return '턴이 스킵되었습니다.';
      case 'GAME_TIME_EXPIRED':
        return '게임 시간이 다 되었어요.';

      // �� 매우 자주 발생 (높음) - 게임 종료 관련
      case 'PRESIDENT_LEFT':
        return '게임이 종료되었어요.';
      case 'INSUFFICIENT_PLAYERS':
        return '플레이어가 부족해서 게임이 종료되었어요.';

      // ⚠️ 자주 발생 (중간) - 입장/세션 관련
      case 'INVALID_ENTRY_CODE':
        return '잘못된 입장 코드입니다.';
      case 'SESSION_NOT_FOUND':
        return '세션을 찾을 수 없습니다.';
      case 'PLAYER_ALREADY_JOINED':
        return '이미 참여한 게임입니다.';

      // ⚠️ 자주 발생 (중간) - 게임 상태 관련
      case 'NOT_REGISTERED_PLAYER':
        return '순서를 등록하지 않아서 입장할 수 없었어요.';
      case 'WRONG_GAME_STATE':
        return '오류가 발생했어요 다시 참여해주세요.';
      case 'GAME_IN_PROGRESS':
        return '이미 진행중인 게임입니다.';

      // 🟡 가끔 발생 (낮음) - 권한/턴 관련
      case 'NOT_PRESIDENT':
        return '방장만 가능한 작업입니다.';
      case 'NOT_CURRENT_TURN':
        return '현재 턴이 아닙니다.';
      case 'ALREADY_ORDERED':
        return '이미 순서에 등록되었습니다.';

      // �� 가끔 발생 (낮음) - 동전 관련
      case 'INVALID_COIN_STATE':
        return '잘못된 동전 상태입니다.';
      case 'COIN_NOT_SET':
        return '동전이 설정되지 않았어요.';
      case 'INVALID_COIN_TYPE':
        return '잘못된 동전 타입입니다.';

      // �� 거의 발생 안함 (매우 낮음) - 시스템 오류
      case 'INTERNAL_SERVER_ERROR':
        return '서버 내부 오류가 발생했어요.';
      case 'SESSION_CREATION_FAILED':
        return '세션 생성에 실패했습니다.';
      case 'PLAYER_NOT_FOUND':
        return '플레이어를 찾을 수 없습니다.';

      // �� 거의 발생 안함 (매우 낮음) - 특수 상황
      case 'LEE_SOON_SIN_TRIGGERED':
        return '이순신이 나타났습니다!';
      case 'NOT_LEE_SOON_SIN_STATE':
        return '이순신 상태가 아닙니다.';
      case 'PLAYER_TIMEOUT':
        return '플레이어 응답 시간이 초과되었습니다.';
      case 'ORDER_NOT_REGISTERED':
        return '순서가 등록되지 않았습니다.';
      case 'GAME_NOT_STARTED':
        return '게임이 시작되지 않았습니다.';
      case 'INVALID_MESSAGE_TYPE':
        return '잘못된 메시지 타입입니다.';

      case 'RATE_LIMIT_EXCEEDED':
        return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';

      default:
        return '알 수 없는 오류가 발생했어요.';
    }
  }

  // 게임 종료가 필요한 에러인지 확인
  static bool isGameEndingError(String errorCode) {
    switch (errorCode) {
      case 'PRESIDENT_LEFT':
      case 'INSUFFICIENT_PLAYERS':
      case 'NOT_REGISTERED_PLAYER':
        return true;
      default:
        return false;
    }
  }

  // 재연결이 필요한 에러인지 확인
  static bool isReconnectionError(String errorType) {
    switch (errorType) {
      case 'NETWORK_TIMEOUT':
      case 'CONNECTION_LOST':
        return true;
      default:
        return false;
    }
  }
}
