import 'package:flutter/material.dart';
import 'package:flutter_chat/services/auth_service.dart';
import 'chat_screen.dart';

class AuthScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  void _signln(String email, String password) async {
    final user = await _authService.signInWithEmail(email, password);

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen()),
      );
    } else {}
  }
  @override
  Widget build(BuildContext context){}
}
