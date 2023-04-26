import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter_pi/pages/home.dart';

// Page to verify a new user's email address before authenticating them
class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _emailVerified = false;
  DateTime _lastResend = DateTime.now();
  Timer? _checkVerificationTimer;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();

    // Gets the current verification state
    _emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    // If not yet verified, send a verification email and start timers
    if (!_emailVerified) {
      sendVerificationEmail(context, false);
    
      // Checks if the email has been verified every 3 seconds
      _checkVerificationTimer = Timer.periodic(
        const Duration(seconds: 3), 
        (_) => checkVerificationStatus()
      );

      // Refreshes state every second
      _resendTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {})
      );
    }
  }

  // Ensures timers are correctly disposed
  @override
  void dispose() {
    _checkVerificationTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _emailVerified ? HomePage() : 
    Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Awaiting Email Verification")
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                "A verification email has been sent to your email.\n"
                "Please click the link in the email to activate your account!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24
                ),
              ),
            const SizedBox(height: 40),
            Button(
              buttonText: "Resend Email",
              onPressed: DateTime.now().difference(_lastResend).inSeconds > 60 
                ? (c) => sendVerificationEmail(c, true) : null,
              width: 500,
            ),
            const SizedBox(height: 15),
            Text(
                "Please wait ${60 - DateTime.now().difference(_lastResend).inSeconds} seconds to send another email.", 
                style: TextStyle(
                  fontSize: DateTime.now().difference(_lastResend).inSeconds > 60 ? 0 : 16,
                  color: const Color.fromARGB(255, 255, 0, 0),
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 15),
            RichText(
              text: TextSpan(
                recognizer: TapGestureRecognizer()..onTap = () { 
                  _checkVerificationTimer?.cancel();
                  _resendTimer?.cancel();
                  FirebaseAuth.instance.signOut(); 
                },
                text: "Cancel",
                style: TextStyle(
                  decoration: TextDecoration.underline, 
                  color: Theme.of(context).buttonTheme.colorScheme?.primary
                )
              )
            )
          ],
        )
      )
    );

  // Attempts to send a verification user to the user
  Future<void> sendVerificationEmail(BuildContext context, bool showLoadSymbol) async {
    // Shows loading icon
    if (showLoadSymbol) {
      showDialog(
        context: context,
        barrierDismissible: false, 
        builder: (context) => const Center(child: CircularProgressIndicator()), 
      );
    }

    // Attempts to user FirebaseAuth to send a new verification email
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() {
        _lastResend = DateTime.now();
        _resendTimer?.cancel();
        _resendTimer = Timer.periodic(
          const Duration(seconds: 1),
          (_) => setState(() {})
        );
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    if (showLoadSymbol && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // Checks the current verification status of the user
  Future<void> checkVerificationStatus() async {
    await FirebaseAuth.instance.currentUser!.reload();
    
    setState(() {
      _emailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (_emailVerified) _checkVerificationTimer?.cancel();
  }
}

