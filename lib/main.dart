// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/my_profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/main_app_screen.dart'; // <--- pastikan ini di-import

// Warna utama aplikasi
const Color kPrimaryColor = Color(0xFF6ABF4B);
const Color kTextColor = Color(0xFF202E2E);
const Color kTextLightColor = Color(0xFF728080);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kede Grocery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: kPrimaryColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: kTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          bodyMedium: TextStyle(
            color: kTextLightColor,
            fontSize: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kPrimaryColor, width: 2),
            foregroundColor: kPrimaryColor,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // Gunakan AuthWrapper untuk menentukan halaman awal
      home: const AuthWrapper(),

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/my-profile': (context) => const MyProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}

// Wrapper untuk menentukan halaman awal sesuai status login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Jika sudah login, langsung ke MainAppScreen
      return const MainAppScreen();
    }

    // Jika belum login, tampilkan Onboarding
    return const OnboardingScreen();
  }
}
