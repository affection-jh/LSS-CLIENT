import 'package:esc/data/player.dart';

class Session {
  final String sessionId;
  final String entryCode;
  final String presidentId;
  final List<Player> players;
  final int currentPlayerIndex;
  final bool isClockWise;
  String? firstCoinState;
  String? secondCoinState;
  final Player? currentPlayer;
  final bool isMyTurn;
  final bool isPresident;
  final String gameState;
  DateTime? gameEndTime;

  Session({
    required this.sessionId,
    required this.entryCode,
    required this.presidentId,

    required this.players,
    required this.currentPlayerIndex,
    required this.isClockWise,
    this.firstCoinState,
    this.secondCoinState,
    this.currentPlayer,
    required this.isMyTurn,
    required this.isPresident,
    required this.gameState,
    this.gameEndTime,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'],
      entryCode: json['entryCode']?.toString() ?? '',
      presidentId: json['presidentId'] ?? '',
      players:
          (json['players'] as List?)
              ?.map((playerJson) => Player.fromJson(playerJson))
              .toList() ??
          [],
      currentPlayerIndex: json['currentPlayerIndex'] ?? 0,
      isClockWise: json['clockWise'] ?? json['isClockWise'] ?? true,
      firstCoinState: json['firstCoinState'],
      secondCoinState: json['secondCoinState'],
      currentPlayer: json['currentPlayer'] != null
          ? Player.fromJson(json['currentPlayer'])
          : null,
      isMyTurn: json['myTurn'] ?? json['isMyTurn'] ?? false,
      isPresident: json['president'] ?? json['isPresident'] ?? false,
      gameState: json['gameState'] ?? 'WAITING_ROOM',
      gameEndTime: json['gameEndTime'] != null
          ? DateTime.tryParse(json['gameEndTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'entryCode': entryCode,
      'presidentId': presidentId,
      'players': players.map((player) => player.toJson()).toList(),
      'currentPlayerIndex': currentPlayerIndex,
      'isClockWise': isClockWise,
      'firstCoinState': firstCoinState,
      'secondCoinState': secondCoinState,
      'currentPlayer': currentPlayer?.toJson(),
      'isMyTurn': isMyTurn,
      'isPresident': isPresident,
      'gameState': gameState,
      'gameEndTime': gameEndTime?.toIso8601String(),
    };
  }
}
