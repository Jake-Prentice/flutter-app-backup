import 'package:flutter/material.dart';
import 'package:flutter_pi/pages/auth/login.dart';
import 'package:flutter_pi/pages/auth/register.dart';

// Page shown to unauthorised users
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool registering = false;

  @override
  Widget build(BuildContext context) => registering 
    ? RegisterPage(onToggle: toggleAuthPage) 
    : LoginPage(onToggle: toggleAuthPage);

  // Toggles page between login and registration page
  void toggleAuthPage() => setState(() => registering = !registering);
}

