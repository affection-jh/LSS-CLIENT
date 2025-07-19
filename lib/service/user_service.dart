import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc/data/player.dart';

class UserService {
  // 싱글톤 패턴
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // static 변수들을 인스턴스 변수로 변경
  String? _userId;
  String _name = '';
  String _profileImageUrl = '';

  // getter들
  String? get userId => _userId;
  String get nickname => _name;
  String? get profileImageUrl => _profileImageUrl;

  // static getter로 기존 코드와 호환성 유지
  Future<bool> initializeUser(String id) async {
    try {
      _userId = id;
      await FirebaseFirestore.instance.collection('users').doc(id).get().then((
        value,
      ) {
        _name = value.data()?['nickname'] ?? '';
        _profileImageUrl = value.data()?['profileImageUrl'] ?? '';
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Player? getUser() {
    if (_userId == null) {
      return null;
    }
    return Player(
      userId: _userId!,
      name: _name,
      profileImageUrl: _profileImageUrl,
    );
  }

  Future<bool> updateNickname(String newNickname) async {
    try {
      if (_userId == null) return false;

      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'nickname': newNickname,
      });

      _name = newNickname;
      return true;
    } catch (e) {
      print('닉네임 업데이트 실패: $e');
      return false;
    }
  }

  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      if (_userId == null) return false;

      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'profileImageUrl': imageUrl,
      });

      _profileImageUrl = imageUrl;
      return true;
    } catch (e) {
      print('프로필 이미지 업데이트 실패: $e');
      return false;
    }
  }
}
