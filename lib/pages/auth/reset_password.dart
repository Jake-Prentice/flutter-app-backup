import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';

// Page to reset an account's password if it's been forgotten
class ResetPasswordPage extends StatefulWidget {
  ResetPasswordPage({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _validateInputs = false;
  String _formErrorMessage = "";
  String _formSuccessMessage = "";
  
  // Text Controller for email input
  final emailController = TextEditingController();

  // Ensures text editing controller is correctly disposed
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text("Reset Password")),
    body: Padding(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: widget.formKey, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your email to reset your password.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24
              ),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: emailController,
              cursorColor: Colors.white,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: "Email"),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => _validateInputs && value != null && !EmailValidator.validate(value.trim()) ? 
                  "Please enter a valid email address" : null,
            ),
            const SizedBox(height: 20),
            Button(
              buttonText: "Reset Password",
              onPressed: resetPassword,
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
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                text: _formSuccessMessage,
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: _formSuccessMessage.isEmpty ? 0 : 16
                ),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = () => Navigator.of(context).popUntil((route) => route.isFirst),
                    text: "Go Back",
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
    )
  );

  // Attempts to send a password reset request using the current form contents
  Future<void> resetPassword (BuildContext context) async {
    // Resets state
    setState(() {
      _validateInputs = true;
      _formErrorMessage = "";
      _formSuccessMessage = "";
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

    // Attempts to send password reset email using FirebaseAuth
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      setState(() => _formSuccessMessage = "Password reset email sent!   ");
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      setState(() => _formErrorMessage = e.message ?? "");
    }

    if (context.mounted) Navigator.of(context).pop();
  }
}

