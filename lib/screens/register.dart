import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/screens/home.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
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
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  void _login(BuildContext context) async {
    await Navigator.push(context,
      MaterialPageRoute(builder: (context) => Login()),
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
            primary: false,
            actions: <Widget>[
              TextButton.icon(
                  icon: Icon(Icons.person, color: Colors.black),
                  label: Text(
                    "Se connecter", style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    _login(context);
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
                  margin: EdgeInsets.symmetric(horizontal: 50),
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
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "NOM...",
                    ),
                    obscureText: true,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    controller: surnameController,
                    decoration: InputDecoration(
                      hintText: "PRENOM...",
                    ),
                    obscureText: true,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: "TELEPHONE...",
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
                      final String name = nameController.text.trim();
                      final String surname = surnameController.text.trim();
                      final String phone = phoneController.text.trim();
                      final double credit = 10;
                      final DateTime date = new DateTime.now();

                      if (email.isEmpty) {
                        print("Email is Empty");
                      } else {
                        if (password.isEmpty) {
                          print("Password is Empty");
                        } else {
                          if (name.isEmpty) {
                            print("Name is Empty");
                          } else {
                            if (surname.isEmpty) {
                              print("Surname is Empty");
                            } else {
                              if (phone.isEmpty) {
                                print("Phone is Empty");
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
                    child: Text("S'inscrire"),
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
