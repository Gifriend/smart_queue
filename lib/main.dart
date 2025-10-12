import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_queue/screens/splash_screen.dart';

import 'firebase_options.dart'; // File ini di-generate oleh FlutterFire CLI
import 'services/firestore_service.dart';

void main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menyediakan FirestoreService ke seluruh aplikasi menggunakan Provider
    // DIUBAH: dari ChangeNotifierProvider menjadi Provider
    return Provider<FirestoreService>(
      create: (context) => FirestoreService(),
      child: MaterialApp(
        title: 'SmartQueue BSG',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Color Palette
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE72229), // merah sebagai primary
            primary: const Color(0xFF8F070A),
            secondary: const Color(
              0xFFE72229,
            ), // Orange sebagai secondary/accent
            background: Colors.grey.shade100,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            elevation: 4.0,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF0D47A1),
            foregroundColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
