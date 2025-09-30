import 'package:flutter/material.dart';

import 'Login.dart';

class HomeScreen extends StatelessWidget {const HomeScreen({super.key});

@override
Widget build(BuildContext context) {
  return const Center(
    child: Text('Home Screen', style: TextStyle(fontSize: 24)),
  );
}
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Search Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Profile Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Screen', style: TextStyle(fontSize: 24)),
    );
  }
}

// For Logout, you might navigate away or show a dialog.
// For this example, we'll just show a simple screen.
class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Center(
          child: Text('Logout Screen', style: TextStyle(fontSize: 24)),
        ),
        ElevatedButton(onPressed: (){
          setState((){
            Navigator.push(context,  MaterialPageRoute(builder: (context)=> LoginScreen()));
          });
        },child: Icon(Icons.logout),),
      ],
    );
  }
}