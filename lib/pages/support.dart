import 'package:flutter/material.dart';
import 'package:flutter_pi/services/sendmail.dart';
import 'package:flutter_pi/provider/text_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_pi/navigation_drawer.dart';
import 'package:flutter_pi/buttons/button.dart';
import 'package:flutter_pi/main.dart';

class FeedBackPage extends StatefulWidget {
  FeedBackPage({super.key});

  final user = FirebaseAuth.instance.currentUser!;
  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final _formKey = GlobalKey<FormState>();
  bool _enableBtn = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      setState(() {
        _enableBtn = messageController.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Technical support"),
      ),
      drawer: AppNavigationDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        ),
        child: const Icon(Icons.home_rounded),
      ),
      body:

      Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 70, left:20, right:20),
                  child: Text(
                    "Describe your issue and submit your request!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                SizedBox(
                  width: 380, // custom width
                  child: TextFields(
                    controller: subjectController,
                    name: "Subject",
                    validator: ((value) {
                      if (value!.isEmpty) {
                        return 'Subject is required';
                      }
                      return null;
                    }),
                  ),
                ),
                SizedBox(
                  width: 380, // custom width
                  child: TextFields(
                    controller: messageController,
                    name: "Message",
                    validator: ((value) {
                      if (value!.isEmpty) {
                        return 'Message is required';
                      }
                      return null;
                    }),
                    maxLines: null,
                    type: TextInputType.multiline,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Button(
                    buttonText: "Submit",
                    onPressed: (BuildContext context) async {
                      await sendMail(
                        email: widget.user.email.toString(),
                        subject: subjectController.text,
                        body: messageController.text,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}