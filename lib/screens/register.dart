import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liguey/translations.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController surnameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  void _success(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  void _login(BuildContext context) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => Login()),
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
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                  child: Center(
                    child: Text(
                      Translations.of(context, 'welcome'),
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Translations.of(context, 'email'),
                      hintText: Translations.of(context, 'email'),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Translations.of(context, 'password'),
                      hintText: Translations.of(context, 'password'),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Translations.of(context, 'name'),
                      hintText: Translations.of(context, 'name'),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: surnameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Translations.of(context, 'surname'),
                      hintText: Translations.of(context, 'surname'),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Translations.of(context, 'phone'),
                      hintText: Translations.of(context, 'phone'),
                    ),
                    textInputAction: TextInputAction.done, // Hides the keyboard.
                    keyboardType: TextInputType.number,
                  ),
                ),
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                      color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () {
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();
                      final String name = nameController.text.trim();
                      final String surname = surnameController.text.trim();
                      final String phone = phoneController.text.trim();
                      final double credit = 10;
                      final DateTime date = new DateTime.now();

                      if (email.isEmpty) {
                      } else {
                        if (password.isEmpty) {
                        } else {
                          if (name.isEmpty) {
                          } else {
                            if (surname.isEmpty) {
                            } else {
                              if (phone.isEmpty) {
                              } else {
                                context.read<AuthService>().register(
                                  email,
                                  password,
                                  name,
                                  surname,
                                  phone,
                                  credit,
                                  date,
                                ).whenComplete(() => _success(context));
                              }
                            }
                          }
                        }
                      }
                    },
                    child: Text(Translations.of(context, 'inscription')),
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
