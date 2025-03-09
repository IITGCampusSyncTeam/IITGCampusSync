import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        title: const Text('USER SIGN UP'),
        centerTitle: true,
      ),
        body:Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async{

                },
                child: const Text('login with outlook '),
              )
            ],
          ),
        ));
  }
}
