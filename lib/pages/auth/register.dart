import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter_pi/user_data/user_stats.dart';
import 'package:flutter/services.dart';

// Registration page to allow users to create a new account
class RegisterPage extends StatefulWidget {
  RegisterPage({super.key, required this.onToggle});

  final VoidCallback onToggle;
  final formKey = GlobalKey<FormState>();

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _validateInputs = false;
  String _formErrorMessage = "";

  // Text Controllers for new user details input
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final weightController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Ensures text editing controllers are correctly disposed
  @override
  void dispose() {
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    weightController.dispose();
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
                controller: displayNameController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: "Name"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    _validateInputs && value != null && value.trim().isEmpty
                        ? "Please enter your name"
                        : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: "Email"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => _validateInputs &&
                        value != null &&
                        !EmailValidator.validate(value.trim())
                    ? "Please enter a valid email address"
                    : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: weightController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: "Current Weight"),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                validator: (value) {
                  if (_validateInputs && value != null) {
                    final double weight = double.tryParse(value) ?? 0.0;
                    if (weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: passwordController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) =>
                    _validateInputs && value != null && value.trim().length < 6
                        ? "Password must be at least 6 characters"
                        : null,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: confirmPasswordController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(labelText: "Confirm Password"),
                obscureText: true,
                validator: (value) => _validateInputs &&
                        value != null &&
                        value.trim() != passwordController.text.trim()
                    ? "Passwords must match"
                    : null,
              ),
              const SizedBox(height: 20),
              Button(
                buttonText: "Register",
                onPressed: register,
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
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      text: "Already have an account? ",
                      children: [
                    TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = widget.onToggle,
                        text: "Sign in",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Theme.of(context)
                                .buttonTheme
                                .colorScheme
                                ?.primary))
                  ]))
            ],
          )));

  // Attempts to register a new user using the current form contents
  Future<void> register(BuildContext context) async {
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

    // Attempts to create new user using FirebaseAuth
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim());

      // Uses new user information to create user document in the database
      User newUser = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(newUser.uid)
          .set({
            "uid": newUser.uid,
            "email": newUser.email,
            "name": displayNameController.text.trim(),
            "stepsGoal": 4000,
            "moodGoal": 6,
            "activitiesGoal": 30,
            "stats": UserStats.defaultMap,
             "weight": double.tryParse(weightController.text)
          })
          .then((value) => debugPrint("User data added successfully."))
          .catchError((error) => debugPrint("Failed to add user data: $error"));
    } on FirebaseAuthException catch (e) {
      setState(() => _formErrorMessage = e.message ?? "");
      if (context.mounted)
        Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}
