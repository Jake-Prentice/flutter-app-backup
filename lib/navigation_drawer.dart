import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pi/main.dart';
import 'package:flutter_pi/pages/account.dart';
import 'package:flutter_pi/pages/log_data.dart';
import 'package:flutter_pi/pages/progress_graphs.dart';
import 'package:flutter_pi/pages/history.dart';
import 'package:flutter_pi/pages/support.dart';
import 'package:flutter_pi/user_data/user_data.dart';

class AppNavigationDrawer extends StatelessWidget {
  AppNavigationDrawer({super.key});
  final user = FirebaseAuth.instance.currentUser!;
  final UserData userData = UserData.createInstance(
      FirebaseAuth.instance.currentUser!
  );

  @override
  Widget build(BuildContext context) => Drawer(
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 24 + MediaQuery.of(context).padding.top,
              bottom: 24
            ),
          ),
          buildDrawerItems(context)
        ],
      ),
    ),
  );

  Widget buildDrawerItems(BuildContext context) => Container(
    padding: const EdgeInsets.all(24), 
    child: Wrap(
      runSpacing: 16,
      children: [
        UserAccountsDrawerHeader( // <-- SEE HERE
          decoration: BoxDecoration(),
          accountName: Text(
            userData.username,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          accountEmail: Text(
            user.email.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          currentAccountPicture: FlutterLogo(),
        ),
        ListTile(
          leading: const Icon(Icons.home_rounded),
          title: const Text("Home"),
          onTap: () => navigateTo(context, const MainPage())
        ),
        ListTile(
          leading: const Icon(Icons.add_rounded),
          title: const Text("Log Data"),
          onTap: () => navigateTo(context, LogDataPage())
        ),
        ListTile(
          leading: const Icon(Icons.timeline_rounded),
          title: const Text("Progress"),
          onTap: () => navigateTo(context, const ProgressGraphsPage())
        ),
        ListTile(
          leading: const Icon(Icons.description_rounded),
          title: const Text("History"),
          onTap: () => navigateTo(context, HistoryPage())
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.account_circle_rounded),
          title: const Text("Your Account"),
          onTap: () => navigateTo(context, AccountPage()),
        ),
        ListTile(
            leading: const Icon(Icons.help),
            title: const Text("Technical support"),
            onTap: () => navigateTo(context, FeedBackPage())
        ),
        ListTile(
          leading: const Icon(Icons.logout_rounded),
          title: const Text("Log Out"),
          onTap: () { 
            navigateTo(context, const MainPage());
            FirebaseAuth.instance.signOut(); 
          }
        ),
      ],
    )
  );

  void navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: 
      (context) => page
    ));
  }
}