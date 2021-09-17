import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liguey/screens/login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String Test = "";
  @override
  void initState() {
    super.initState();
  }

  final databaseRef = FirebaseDatabase.instance.reference();
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  void addData() {
    databaseRef.child("test").push().set({'name': "data", 'comment': 'A good season'});
  }

  void printFirebase(){
    databaseRef.child("Version").child("code").once().then((DataSnapshot snapshot) {
      print('Data : ${snapshot.value}');
      Test = 'Data : ${snapshot.value}';
    });
  }

  Future <Home?> _signOut()  async{
    await FirebaseAuth.instance.signOut();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liguey'),
          backgroundColor: Color(0xFFE0BF92),
          actions: <Widget> [
            TextButton.icon(
                    icon: Icon(Icons.person, color: Colors.black),
                    label: Text("Se déconnecter", style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async{
                      await _signOut();
                    }
                )
          ],
        ),
        body: ListView(
          children: [
            Image.asset(
              'images/welcome_liguey.jpg',
              width: 600,
              height: 240,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}

class _auth {
}
