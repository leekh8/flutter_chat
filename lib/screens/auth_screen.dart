import 'package:flutter/material.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'chat_screen.dart';

class AuthScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _signln(BuildContext context, String email, String password) async {
    // 인증 서비스 호출해 사용자 인증
    // 인증 성공하면 Navigator 사용해 ChatScreen으로 이동
    final user = await _authService.signInWithEmail(email, password);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sign In'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {},
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (value) {},
              ),
              ElevatedButton(
                onPressed: () {
                  _signln(context, 'email@example.com', 'password123');
                },
                child: Text('Sigin In'),
              ),
            ],
          ),
        ));
  }
}
