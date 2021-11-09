import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/screens/cv.dart';
import 'package:flutter_liguey/screens/picture.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter_liguey/translations.dart';
import 'package:provider/src/provider.dart';

class Profil extends StatefulWidget {

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {

  var name, email, phone, image, uid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final user = context.watch<User?>();

    final Map arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map;
    uid = arguments['id'];
    name = arguments['name'];
    email = arguments['email'];
    phone = arguments['phone'];

    void _success(BuildContext context) async {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
            (Route<dynamic> route) => false,
      );
    }

    Widget imageSection = Container(
      padding: EdgeInsets.all(8),
      color: Color(0xFFC78327),

      child: FutureBuilder(
        future: _loadImage(uid),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.toString() != "null") {
              return Container(
                child: Image.network(snapshot.data.toString(),
                    fit: BoxFit.cover),
              );
            } else {
              return Container(
                  width: 200,
                  height: 200,
                  child: Image.asset('images/liguey.png', fit: BoxFit.fill)
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );

    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      phone,
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Picture(),
                              settings: RouteSettings(
                                arguments: {
                                  'id': uid,
                                  'name': name,
                                },
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Photo",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
              alignment: Alignment.center,
              child: RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                      child: Icon(Icons.logout, size: 15.0, color: Colors.blue,
                      ),
                    ),
                    TextSpan(
                        text: Translations.of(context, 'deconnexion'),
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15.0,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await context.read<AuthService>().signOut().whenComplete(() => _success(context));
                          }),
                  ]))
          ),
        ],
      ),
    );

    Color color = Theme
        .of(context)
        .primaryColor;

    Widget buttonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(color, Icons.add_a_photo, 'Photo'),
        _buildButtonColumn(color, Icons.description, 'CV'),
      ],
    );

    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liguey'),
          backgroundColor: Color(0xFFE0BF92),
        ),
        body: ListView(
          children: [
            imageSection,
            buttonSection,
            titleSection,
          ],
        ),
      ),
    );
  }

  Widget _buildButtonColumn(Color color, IconData icon, String label) {
    return GestureDetector(
      onTap: () async {
        if (label == "Photo") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Picture(),
              settings: RouteSettings(
                arguments: {
                  'id': uid,
                  'name': name,
                },
              ),
            ),
          );
        } else if (label == "CV") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CV(),
              settings: RouteSettings(
                arguments: {
                  'id': uid,
                  'name': name,
                },
              ),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: color, size: 40,),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _loadImage(String image) async {
    String result = await FirebaseStorage.instance.ref().child("images").child(image).getDownloadURL();
    return result;
  }
}