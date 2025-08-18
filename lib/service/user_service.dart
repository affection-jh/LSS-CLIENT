import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc/data/player.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  // 싱글톤 패턴
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // static 변수들을 인스턴스 변수로 변경
  String? _userId;
  String _name = '';
  String _profileImageUrl = '';
  bool _isGuestmode = false;

  // getter들
  String? get userId => _userId;
  String get name => _name;
  String? get profileImageUrl => _profileImageUrl;
  bool get isGuestmode => _isGuestmode;

  void setGuestPlayer(String userId, String? name) {
    _userId = userId;
    _name = name ?? "";
    _isGuestmode = true;

    print(
      "게스트 플레이어 설정 - userId: $_userId, name: $_name, isGuest: $_isGuestmode",
    );
  }

  // static getter로 기존 코드와 호환성 유지
  Future<bool> initializeUser(String id) async {
    try {
      // 기존 데이터 정리 (게스트 모드에서 로그인으로 전환 시)
      cleanUserData();

      await FirebaseFirestore.instance.collection('users').doc(id).get().then((
        value,
      ) {
        _userId = value.data()?['userId'] ?? '';
        _name = value.data()?['name'] ?? '';
        _profileImageUrl = value.data()?['profileImageUrl'] ?? '';
        _isGuestmode = false; // 로그인 사용자는 게스트 모드 아님
      });

      print(
        "로그인 사용자 초기화 - userId: $_userId, name: $_name, isGuest: $_isGuestmode",
      );
      return _userId != null;
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

  Future<bool> updateNickname(String name) async {
    try {
      if (_userId == null) return false;

      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'name': name,
      });

      _name = name;
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

  void cleanUserData() {
    _userId = null;
    _name = "";
    _profileImageUrl = "";
    _isGuestmode = false;
    print("사용자 데이터 정리 완료");
  }

  // 게스트 데이터만 정리 (SharedPreferences 포함)
  Future<void> cleanGuestData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("guest_name");
      await prefs.remove("guest_id");
      print("게스트 데이터 정리 완료");
    } catch (e) {
      print("게스트 데이터 정리 실패: $e");
    }
  }

  /// 프로필 이미지를 파이어베이스 Storage에 업로드하고 Firestore에 URL 저장
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      if (_userId == null) return false;

      // 기존 프로필 이미지가 있으면 먼저 삭제
      if (_profileImageUrl.isNotEmpty) {
        await _deleteExistingProfileImage(_profileImageUrl);
      }

      final fileName =
          'profile_images/${_userId}/${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      // Firestore에 저장
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'profileImageUrl': downloadUrl,
      });
      _profileImageUrl = downloadUrl;
      return true;
    } catch (e) {
      print('프로필 이미지 업로드 실패: $e');
      return false;
    }
  }

  /// 기존 프로필 이미지 삭제
  Future<void> _deleteExistingProfileImage(String imageUrl) async {
    try {
      // Firebase Storage URL인지 확인
      if (imageUrl.startsWith('https://firebasestorage.googleapis.com/')) {
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
        print('기존 프로필 이미지 삭제 완료: $imageUrl');
      } else {
        print('Firebase Storage 이미지가 아니므로 삭제 건너뜀: $imageUrl');
      }
    } catch (e) {
      print('기존 프로필 이미지 삭제 실패 (무시하고 진행): $e');
      // 삭제 실패해도 새 업로드는 진행
    }
  }

  /// 프로필 이미지 삭제 (사용자가 직접 삭제)
  Future<bool> deleteProfileImage() async {
    try {
      if (_userId == null) return false;

      // Storage에서 이미지 삭제
      if (_profileImageUrl.isNotEmpty) {
        await _deleteExistingProfileImage(_profileImageUrl);
      }

      // Firestore에서 URL 제거
      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'profileImageUrl': '',
      });

      _profileImageUrl = '';
      return true;
    } catch (e) {
      print('프로필 이미지 삭제 실패: $e');
      return false;
    }
  }
}
