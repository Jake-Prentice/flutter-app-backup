import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter_pi/pages/auth/reset_password.dart';

// Login page to allow users to sign in with an email and password
class LoginPage extends StatefulWidget {
  LoginPage({super.key, required this.onToggle});

  final VoidCallback onToggle;
  final formKey = GlobalKey<FormState>();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _validateInputs = false;
  String _formErrorMessage = "";
  
  // Text Controllers for email and password Input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Ensures text editing controllers are correctly disposed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(40),
    child: Form(
      key: widget.formKey, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FlutterLogo(size: 120),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Email"),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateInputs && value != null && !EmailValidator.validate(value.trim()) ? 
                "Please enter a valid email address" : null,
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _passwordController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => _validateInputs && value != null && value.trim().length < 6 ? 
                "Password must be at least 6 characters" : null,
          ),
          const SizedBox(height: 20),
          Button(
            buttonText: "Sign in",
            onPressed: signIn,
            width: 500,
          ),
          const SizedBox(height: 6),
          Text(
            _formErrorMessage, 
            style: TextStyle(
              fontSize: _formErrorMessage.isEmpty ? 0 : 12,
              color: const Color.fromARGB(255, 255, 0, 0),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          RichText(
            text: TextSpan(
              recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(),
                )
              ),
              text: "Forgotten your password?",
              style: TextStyle(
                decoration: TextDecoration.underline, 
                color: Theme.of(context).buttonTheme.colorScheme?.primary,
                fontSize: 16,
              )
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 16),
              text: "No account? ",
              children: [
                TextSpan(
                  recognizer: TapGestureRecognizer()..onTap = widget.onToggle,
                  text: "Create one!",
                  style: TextStyle(
                    decoration: TextDecoration.underline, 
                    color: Theme.of(context).buttonTheme.colorScheme?.primary
                  )
                )
              ]
            )
          )
        ],
      )
    )
  );

  // Attemps to sign in using the current form contents
  Future<void> signIn(BuildContext context) async {
    // Resets state
    setState(() {
      _validateInputs = true;
      _formErrorMessage = "";
    });

    // Checks if form is valid
    bool isValid = widget.formKey.currentState!.validate();
    if (!isValid) return;

    // Shows loading icon
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator()), 
    );

    // Attempts to sign in using FirebaseAuth
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim()
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _formErrorMessage = e.message ?? "");
      if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}