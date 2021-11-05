import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/screens/register.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liguey/translations.dart';
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
    final user = context.watch<User?>();

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
                    Translations.of(context, 'inscription'), style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    _register(context);
                  }
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Center(
                    child: Container(
                        width: 200,
                        height: 150,
                        /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                        child: Image.asset('images/liguey.png')
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: Translations.of(context, 'email'),
                        hintText: Translations.of(context, 'email')),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: Translations.of(context, 'password'),
                        hintText: Translations.of(context, 'password')
                    ),
                    textInputAction: TextInputAction.done, // Hides the keyboard.
                  ),
                ),
                TextButton(
                  onPressed: (){
                    //TODO FORGOT PASSWORD SCREEN GOES HERE
                  },
                  child: Text(
                    Translations.of(context, 'forgot'),
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  ),
                ),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();

                      if (email.isEmpty) {
                      } else {
                        if (password.isEmpty) {
                        } else {
                          context.read<AuthService>().login(
                            email,
                            password,
                          );
                        }
                      }
                    },
                    child: Text(
                      Translations.of(context, 'connexion'),
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextButton(
                  onPressed: (){
                    _register(context);
                  },
                  child: Text(
                    Translations.of(context, 'newuser'),
                    style: TextStyle(color: Colors.red, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
