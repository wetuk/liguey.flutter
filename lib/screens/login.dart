import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/screens/register.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();


  void _register(BuildContext context) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    if (user != null) {
      return MyApp();
    } else {
      return MaterialApp(
        title: 'Liguey',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Liguey'),
            backgroundColor: Color(0xFFE0BF92),
            actions: <Widget>[
              TextButton.icon(
                  icon: Icon(Icons.person, color: Colors.black),
                  label: Text(
                    "S'inscrire", style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    _register(context);
                  }
              )
            ],
          ),
          body: Center(
            child: ListView(
              children: [
                Text("Se connecter / S'inscrire"),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "EMAIL...",
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "MOT DE PASSE...",
                    ),
                    obscureText: true,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  height: 40,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 3,
                  color: Color(0xFFE0BF92),
                  child: TextButton(
                    onPressed: () {
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();

                      if (email.isEmpty) {
                        print("Email is Empty");
                      } else {
                        if (password.isEmpty) {
                          print("Password is Empty");
                        } else {
                          context.read<AuthService>().login(
                            email,
                            password,
                          );
                        }
                      }
                    },
                    child: Text("Se connecter"),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
