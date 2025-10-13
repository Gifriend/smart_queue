// lib/screens/home_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_queue/models/user_model.dart';
import 'package:smart_queue/screens/queue_screen.dart';
import 'package:smart_queue/services/auth_service.dart';

import 'history_screen.dart'; // Pastikan import ini ada

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = Provider.of<User?>(context);

    return FutureBuilder<UserModel?>(
      future: authService.getUserData(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(body: Center(child: Text("Gagal memuat data user")));
        }

        final userModel = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text(
              'Antrian ${userModel.role == "admin" ? "(Admin)" : ""}',
            ),
            actions: [
              if (userModel.role == "admin")
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'Lihat Semua Riwayat',
                  onPressed: () {
                    Navigator.push(
                      context,
                      // Admin melihat semua riwayat
                      MaterialPageRoute(
                        builder: (context) =>
                            const HistoryScreen(isAdmin: true),
                      ),
                    );
                  },
                ),
              if (userModel.role == "user")
                IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: userModel.role == 'admin'
                      ? 'Semua Riwayat'
                      : 'Riwayat Saya',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryScreen(
                          isAdmin: userModel.role == 'admin',
                          userId: userModel.role == 'admin'
                              ? null
                              : user.uid, // Kirim userId jika bukan admin
                        ),
                      ),
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authService.logout();
                },
              ),
            ],
          ),
          // Body sekarang adalah QueueScreen
          body: QueueScreen(user: userModel),
        );
      },
    );
  }
}
