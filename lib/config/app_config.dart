class AppConfig {
  // 개발 환경
  static const String devServerUrl = 'ws://158.179.174.166:8080/ws';

  // 프로덕션 환경 (실제 배포 시 사용)
  static const String prodServerUrl = 'wss://your-production-domain.com/ws';

  // 현재 환경에 따른 서버 URL 반환
  static String get serverUrl {
    return devServerUrl;
  }

  // API 타임아웃 설정
  static const int connectionTimeout = 10000; // 10초
  static const int requestTimeout = 10000; // 10초

  // 게임 설정
  static const int maxPlayers = 50;
  static const int gameDurationMinutes = 10;
}
