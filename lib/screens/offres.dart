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
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:math';

//https://github.com/theandroidclassroom/flutter_realtime_database/blob/master/lib/screens/contacts.dart

class Offres extends StatefulWidget {

  @override
  _OffresState createState() => _OffresState();
}

class _OffresState extends State<Offres> {
  late UserModel annonce;
  late DatabaseReference Ref;
  late double lat=0;
  late double lng=0;
  String day = "";
  String sector = "";
  DatabaseReference dbRef = FirebaseDatabase.instance.reference();
  String dropdownValue = '';
  List<String> sectorlist = [];
  String category = '';

  @override
  void initState() {
    // TODO: implement initState

    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    sectorlist = arguments['sectors'].split(',');
    dropdownValue = sectorlist[0];
    lat = arguments['lat'];
    lng = arguments['lng'];
    category = arguments['category'];
  }

  late Uint8List targetlUinit8List;
  late Uint8List originalUnit8List;

  Future<String> _loadImage(String imageName) async {
    String result = await FirebaseStorage.instance.ref().child("mini").child(imageName).getDownloadURL();

    http.Response response = await http.get(Uri.parse(result));
    originalUnit8List = response.bodyBytes;
    var decodedImage = await decodeImageFromList(originalUnit8List);
    int newHeight = ( decodedImage.height * ( 50 / decodedImage.width)).floor();

    var codec = await ui.instantiateImageCodec(originalUnit8List,
        targetHeight: 50, targetWidth: newHeight);
    var frameInfo = await codec.getNextFrame();
    ui.Image targetUiImage = frameInfo.image;

    ByteData? targetByteData = await targetUiImage.toByteData(format: ui.ImageByteFormat.png);
//    await FirebaseStorage.instance.ref().child("mini").child(imageName).putData(targetByteData!.buffer.asUint8List());

    return result;
  }

  @override
  Widget build(BuildContext context) {

    final user = context.watch<User?>();

    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
            title: new Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                        sector = sectorlist.indexOf(dropdownValue).toString();
                      });
                    },
                    items: sectorlist.map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),
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
                      future: dbRef.child(category).once(),
                      builder: (context, snapshot) {

                        List Offres = [];
                        if (snapshot.hasData && !snapshot.hasError) {
                          Offres.clear();
                          DataSnapshot dataValues = snapshot.data as DataSnapshot;
                          Map<dynamic, dynamic> offres = dataValues.value;
                          offres.forEach((key, values) {
                            if(values["annonceTime"]!=null) {
                              if(sector == "") {
                                Offres.add(values);
                              }else{
                                if(sector == values["sector"]) {
                                  Offres.add(values);
                                }
                              }
                            }
                          });
                          Offres.sort((a, b) {
                            return b["annonceTime"].compareTo(a["annonceTime"]);
                          });

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
                                        leading: FutureBuilder(
                                            future: _loadImage(Offres[index]["id"]),
                                            builder: (context, snapshot){
                                              if (snapshot.data.toString() != "null") {
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  child: CircleAvatar(backgroundImage: NetworkImage(snapshot.data.toString())),
                                                );
                                              } else {
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  child: CircleAvatar(backgroundImage: AssetImage('images/liguey.png')),
                                                );
                                              }
                                            }
                                        ),
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
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                        //return Container(child: Text(category + "s"));
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
}