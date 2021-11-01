import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter_liguey/screens/details.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

//https://github.com/theandroidclassroom/flutter_realtime_database/blob/master/lib/screens/contacts.dart

class Offres extends StatefulWidget {

  @override
  _OffresState createState() => _OffresState();
}

class _OffresState extends State<Offres> {
  var image;
  late UserModel annonce;
  late DatabaseReference Ref;
  late double lat=0;
  late double lng=0;
  String day = "";
  var categories = [""];
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  String _value = 'one';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    lat = arguments['lat'];
    lng = arguments['lng'];

    final user = context.watch<User>();

    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
            title: new Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new DropdownButton<String>(
                  value: _value,
                  items: <DropdownMenuItem<String>>[
                    new DropdownMenuItem(
                      child: new Text('one'),
                      value: 'one',
                    ),
                    new DropdownMenuItem(child: new Text('two'), value: 'two'),
                  ],
                ),
              ],
            ),
            backgroundColor: Color(0xFFE0BF92)
        ),
        body:Column(
          children: <Widget>[
            new Expanded( // added Expanded widget
              child: ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Color(0xFF766651),
                    child: FutureBuilder(
                      future: dbRef.child(arguments['category']).once(),
                      builder: (context, snapshot) {

                        List Offres = [];
                        //List lastOffres = [];
                        if (snapshot.hasData && !snapshot.hasError) {
                          Offres.clear();
                          DataSnapshot? dataValues = snapshot.data as DataSnapshot?;
                          Map<dynamic, dynamic> offres = dataValues!.value;
                          offres.forEach((key, values) {
                            if(values["annonceTime"]!=null) {
                              Offres.add(values);
                            }
                          });
                          Offres.sort((a, b) {
                            return b["annonceTime"].compareTo(a["annonceTime"]);
                          });
                          for(var i =0; i<5; i++) {
                            //lastOffres.add(Offres[i]);
                          };
                          return new ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: Offres.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ListTile(
                                        onTap: () {
                                          if (user != null) {
                                            double dist = Geolocator.distanceBetween(lat, lng, Offres[index]["lat"], Offres[index]["lng"])/1000;

                                            String distance =(dist.round()).toString();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Details(),
                                                settings: RouteSettings(

                                                  arguments: {
                                                    'id': Offres[index]["id"],
                                                    'name': Offres[index]["name"],
                                                    'email': Offres[index]["email"],
                                                    'phone': Offres[index]["phone"],
                                                    'day': Offres[index]["day"],
                                                    'distance': distance,
                                                    'annonceText': Offres[index]["annonceText"],
                                                    'descMessage': Offres[index]["descMessage"],
                                                    'annonceLink': Offres[index]["annonceLink"],
                                                    'r_mail': Offres[index]["r_mail"],
                                                    'r_phone': Offres[index]["r_phone"],
                                                    'rate': Offres[index]["rate"],
                                                    'sector': Offres[index]["sector"],
                                                  },
                                                ),
                                              ),
                                            );
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Login(),
                                              ),
                                            );
                                          }
                                        },
                                        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                        leading: CircleAvatar(backgroundImage: AssetImage("images/liguey.png")),
                                        /*leading: FutureBuilder(
                                            future: _getimage(context, Offres[index]["id"]),
                                            builder: (context, snapshot){
                                              if(snapshot.connectionState == ConnectionState.done){
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  child: CircleAvatar(backgroundImage: image),
                                                );
                                              }

                                              if(snapshot.connectionState == ConnectionState.waiting){
                                                return Container(
                                                  width: MediaQuery.of(context).size.width / 1.2,
                                                  height: MediaQuery.of(context).size.width / 1.2,
                                                  child: CircularProgressIndicator(),
                                                );
                                              }

                                              return Container();
                                            }
                                        ),*/
                                        title: Text(Offres[index]["name"],
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          children: <Widget>[
                                            Text(Offres[index]["annonceText"], style: TextStyle(color: Colors.brown)),
                                            Text(DateFormat('dd/MM/yyyy (HH:mm)').format(new DateTime.fromMillisecondsSinceEpoch(Offres[index]["annonceTime"])), style: TextStyle(color: Colors.brown, fontSize: 10.0)),
                                          ],
                                        ),
                                        trailing: Icon(Icons.keyboard_arrow_right, color: Colors.black26, size: 30.0))
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        return Container(
                            child: Text(arguments['category'] + "s")
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//https://bleyldev.medium.com/how-to-show-photos-from-firestore-in-flutter-6adc1c0e405e
  Future<Widget> _getimage(BuildContext context, String imageName) async {
    await FireStorageService.loadImage(context, imageName).then((value) {

      if(value != null){
        image = NetworkImage(value.toString());
      }else{
        image = AssetImage('images/liguey.png');
      }
    });
    return image;
  }
}

class FireStorageService extends ChangeNotifier {
  FireStorageService();
  static Future<dynamic> loadImage(BuildContext context, String Image) async {
    return await FirebaseStorage.instance.ref().child("images").child(Image).getDownloadURL();
  }
}