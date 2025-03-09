import 'package:flutter/material.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/authentication/login.dart';
import 'home.dart';
class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple[200],
          title: const Text('USER Login'),
          centerTitle: true,
        ),
        body:Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async{
      try {
        await authenticate();

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
             ProfileScreen(),
          ),
        );

      }catch (e) {
        print("failed");
      }
                },
                child: const Text('login with outlook '),
              )
            ],
          ),
        ));
  }
}