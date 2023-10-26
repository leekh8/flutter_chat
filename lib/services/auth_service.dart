import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInWithEmail(String email, String password) async {
    // Firebase 인증 처리하는 메서드
    // 이메일, 비밀번호를 Firebase에 전달하고 인증에 성공하면 UserCredential 반환
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
