import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc/data/player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static Future<User?> signInWithGoogle() async {
    try {
      print("구글 로그인 시작");
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (userCredential.user?.uid != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid);

        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          Player player = Player(
            userId: userCredential.user!.uid,
            name: '',
            profileImageUrl: null,
          );
          await userDoc.set(player.toJson());
        }
      }

      return userCredential.user;
    } catch (e) {
      print("구글 로그인 실패: $e");
      return null;
    }
  }

  static Future<User?> signInwithApple() async {
    try {
      print("Apple 로그인 시작");

      // Apple 로그인 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Firebase Auth용 OAuthCredential 생성
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Firebase Auth로 로그인
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(oauthCredential);

      if (userCredential.user?.uid != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user?.uid);

        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          Player player = Player(
            userId: userCredential.user!.uid,
            profileImageUrl: null,
            name: '',
          );
          await userDoc.set(player.toJson());
        }
      }

      return userCredential.user;
    } catch (e) {
      print("Apple 로그인 실패: $e");
      return null;
    }
  }

  static Future<String?> isSignedIn() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    print("로그아웃 성공");
  }

  static Future<bool> deleteAccount() async {
    try {
      print("회원 탈퇴 시작");
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("로그인된 사용자가 없습니다.");
        return false;
      }

      final userId = user.uid;

      // 1. Firestore에서 사용자 데이터 삭제
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print("사용자 데이터 삭제 완료");

      // 2. 사용자가 참여 중인 세션에서 제거
      final sessionsRef = FirebaseFirestore.instance.collection('sessions');
      final sessionsSnapshot = await sessionsRef
          .where('players', arrayContains: userId)
          .get();

      for (var doc in sessionsSnapshot.docs) {
        final sessionData = doc.data();
        List<String> players = List<String>.from(sessionData['players'] ?? []);

        if (players.contains(userId)) {
          players.remove(userId);

          // 세션의 플레이어 목록 업데이트
          await doc.reference.update({'players': players});

          // 만약 삭제된 사용자가 방장이었다면, 다른 플레이어에게 방장 권한 이전
          if (sessionData['presidentId'] == userId && players.isNotEmpty) {
            await doc.reference.update({'presidentId': players.first});
          }

          // 세션에 플레이어가 없으면 세션 삭제
          if (players.isEmpty) {
            await doc.reference.delete();
          }
        }
      }
      print("세션 데이터 정리 완료");

      // 3. Firebase Auth에서 계정 삭제
      await user.delete();
      print("Firebase Auth 계정 삭제 완료");

      print("회원 탈퇴 성공");
      return true;
    } catch (e) {
      print("회원 탈퇴 실패: $e");
      return false;
    }
  }
}
