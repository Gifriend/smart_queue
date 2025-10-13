import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider.of<User?>(context) akan mendengarkan StreamProvider di main.dart
    final user = Provider.of<User?>(context);

    // Jika user null (belum login), tampilkan LoginScreen
    if (user == null) {
      return const LoginScreen();
    }
    // Jika user ada (sudah login), tampilkan HomeScreen
    else {
      return const HomeScreen();
    }
  }
}
