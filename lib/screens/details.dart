import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liguey/screens/seecv.dart';
import 'package:flutter_liguey/translations.dart';
import 'package:url_launcher/url_launcher.dart';

class Details extends StatefulWidget {

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  var name, annonceText, descMessage, email, phone, rate, distance, image, uid,
      cv;
  bool r_mail = true;
  bool r_phone = true;
  bool vis = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute
        .of(context)!
        .settings
        .arguments as Map;
    uid = arguments['id'];
    name = arguments['name'];
    email = arguments['email'];
    phone = arguments['phone'];
    rate = arguments['rate'];
    distance = arguments['distance'];
    annonceText = arguments['annonceText'];
    descMessage = arguments['descMessage'];
    if (arguments['r_mail']! == "NO") {
      r_mail = false;
    }
    if (arguments['r_phone']! == "NO") {
      r_phone = false;
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
                  height: 300,
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  annonceText,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
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
        _buildButtonColumn(r_phone, color, Icons.call, 'CALL'),
        _buildButtonColumn(r_mail, color, Icons.mail, 'EMAIL'),
        _buildButtonColumn(
            true, color, Icons.location_pin, "Dist: " + distance + " km"),
      ],
    );

    Widget cvSection = Padding(
      padding: EdgeInsets.all(15),
      child: FutureBuilder(
        future: _loadCV(uid),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.toString() != "null") {
              return Container(
                  child: RichText(
                    textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: "CV",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 15.0,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //launch(snapshot.data.toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeeCV(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'url': snapshot.data.toString(),
                                        'name': name,
                                      },
                                    ),
                                  ),
                                );
                              }),
                      ]))
              );
            }
          }
          return Container(
              child: Text("")
          );
        },
      ),
    );

    Widget textSection = Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        descMessage,
        softWrap: true,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Color(0xFFE0BF92),
      ),
      body: ListView(
        children: [
          imageSection,
          cvSection,
          titleSection,
          buttonSection,
          textSection,
        ],
      ),
    );
  }

  Widget _buildButtonColumn(bool visible, Color color, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == "CALL") {
          launch("tel:" + phone);
        } else if (label == "EMAIL") {
          launch("mailto:" + email + ",wetuk.sa@gmail.com");
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Visibility(
            child: Icon(icon, color: color),
            visible: visible,
          ),
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Visibility(
              visible: visible,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//https://bleyldev.medium.com/how-to-show-photos-from-firestore-in-flutter-6adc1c0e405e

  Future<String> _loadImage(String image) async {
    String result = await FirebaseStorage.instance.ref().child("images").child(
        image).getDownloadURL();
    return result;
  }

  Future<String> _loadCV(String image) async {
    String result = await FirebaseStorage.instance.ref().child("cv").child(
        image).getDownloadURL();
    return result;
  }
}