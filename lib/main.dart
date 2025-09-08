// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_petvida/screens/login_screen.dart';
import 'package:flutter_petvida/screens/home_screen.dart';

void main() {
  runApp(const PetVidaApp());
}

class PetVidaApp extends StatelessWidget {
  const PetVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetVida',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    return token != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Exibe um spinner de carregamento enquanto verifica o token
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          // Após a verificação, decide qual tela exibir
          if (snapshot.data == true) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}