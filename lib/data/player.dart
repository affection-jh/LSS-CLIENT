class Player {
  final String userId;
  final String name;
  final String? profileImageUrl;

  Player({required this.userId, required this.name, this.profileImageUrl});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      userId: json['userId'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'name': name, 'profileImageUrl': profileImageUrl};
  }
}
