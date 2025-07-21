import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esc/data/player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return null;
      }

      // 토큰 유효성 검증 (토큰 새로고침 시도)
      try {
        await user.getIdToken(true); // forceRefresh: true
        return user.uid;
      } catch (tokenError) {
        // 토큰이 무효하면 로그아웃 처리
        await FirebaseAuth.instance.signOut();
        return null;
      }
    } catch (e) {
      // 에러 발생 시 안전하게 로그아웃 처리
      try {
        await FirebaseAuth.instance.signOut();
      } catch (signOutError) {}

      return null;
    }
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

      // 0. 사용자 재인증 (최근 로그인 확인)
      try {
        // Google 로그인 사용자인 경우 재인증
        if (user.providerData.any((info) => info.providerId == 'google.com')) {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser != null) {
            final GoogleSignInAuthentication googleAuth =
                await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );
            await user.reauthenticateWithCredential(credential);
          } else {
            print("Google 재인증 실패");
            return false;
          }
        }
        print("사용자 재인증 완료");
      } catch (e) {
        print("재인증 실패: $e");
        return false;
      }

      // 1. Firebase Storage에서 프로필 이미지 삭제
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          final profileImageUrl = userData?['profileImageUrl'] as String?;

          if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
            if (profileImageUrl.startsWith(
              'https://firebasestorage.googleapis.com/',
            )) {
              final ref = FirebaseStorage.instance.refFromURL(profileImageUrl);
              await ref.delete();
              print("프로필 이미지 삭제 완료: $profileImageUrl");
            }
          }
        }
      } catch (e) {
        print("프로필 이미지 삭제 실패 (계속 진행): $e");
      }

      // 2. Firestore에서 사용자 데이터 삭제
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print("사용자 데이터 삭제 완료");

      // 3. 사용자가 참여 중인 세션에서 제거
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

      // 4. Firebase Auth에서 계정 삭제
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
