import 'package:android_intent/android_intent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_liguey/models/firebase_file.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter_liguey/screens/details.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter_liguey/screens/offres.dart';
import 'package:flutter_liguey/screens/sendoffre.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

//Integration Wordpress
//https://ichi.pro/fr/comment-integrer-votre-application-flutter-dans-wordpress-225846033883803
//https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG
//https://github.com/JohannesMilke/firebase_download_example/blob/master/lib/api/firebase_api.dart


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges, initialData:null,
        ),
      ],
      child: MaterialApp(
        title: "APP",
        home: MyLocation(),
      ),
    );
  }
}

class MyLocation extends StatefulWidget {
  @override
  _MyLocationState createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  late Future<List<FirebaseFile>> futureFiles;

  String _address = "";
  String _dateTime="";
  Position? _currentPosition = null;

  late UserModel annonce;
  late DatabaseReference Ref;
  late double lat=0;
  late double lng=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLoc();
  }

  Future <MyApp?> _signOut()  async{
    await FirebaseAuth.instance.signOut();
    return null;
  }

//  User? user = FirebaseAuth.instance.currentUser;
//  String? Uid = FirebaseAuth.instance.currentUser!.uid;

  final dbRef = FirebaseDatabase.instance.reference();

  String log ="";
  String day = "";
  String id = "";
  String name = "";
  String email = "";
  String phone = "";

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();
    if (user != null) {
      log = "Déconnexion";
      id = user.uid;
      name = user.displayName!;
      email = user.email!;
      phone = user.phoneNumber!;
    }else{
      log = "Connexion";
    }
    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liguey'),
          backgroundColor: Color(0xFFE0BF92),
          actions: <Widget> [
            TextButton.icon(
                icon: Icon(Icons.person, color: Colors.black),
                label: Text(log, style: TextStyle(color: Colors.black),
                ),
                onPressed: () async{
                  if (user != null) {
                    await _signOut();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                  }
                }
            )
          ],
        ),
        body: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: Color(0xFFE0BF92),
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.asset(
                  'images/welcome_liguey.jpg',
                  width: 600,
                  height: 300,
                  //fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {

                },
                child: Text(
                  'Poster une annonce...',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Color(0xFF766651),
              child: FutureBuilder(
                future: dbRef.child("Offre").once(),
                builder: (context, snapshot) {

                  List Offres = [];
                  List lastOffres = [];
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
                      lastOffres.add(Offres[i]);
                    };
                    var image;

                    return new ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: lastOffres.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                  onTap: () {
                                    if (user != null) {
                                      double dist = Geolocator.distanceBetween(lat, lng, lastOffres[index]["lat"], lastOffres[index]["lng"])/1000;

                                      String distance =(dist.round()).toString();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Details(),
                                          settings: RouteSettings(

                                            arguments: {
                                              'id': lastOffres[index]["id"],
                                              'name': lastOffres[index]["name"],
                                              'email': lastOffres[index]["email"],
                                              'phone': lastOffres[index]["phone"],
                                              'day': lastOffres[index]["day"],
                                              'distance': distance,
                                              'annonceText': lastOffres[index]["annonceText"],
                                              'descMessage': lastOffres[index]["descMessage"],
                                              'annonceLink': lastOffres[index]["annonceLink"],
                                              'r_mail': lastOffres[index]["r_mail"],
                                              'r_phone': lastOffres[index]["r_phone"],
                                              'rate': lastOffres[index]["rate"],
                                              'sector': lastOffres[index]["sector"],
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
                                      future: _getimage(context, lastOffres[index]["id"]),
                                      builder: (context, snapshot){
                                        if(!snapshot.data.toString().contains("http")){
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(backgroundImage: AssetImage('images/liguey.png')),
                                          );
                                        }else{
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(backgroundImage: NetworkImage(snapshot.data.toString())),
                                          );
                                        }
                                      }
                                  ),
                                  title: Text(lastOffres[index]["name"], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    children: <Widget>[
                                      Text(lastOffres[index]["annonceText"], style: TextStyle(color: Colors.brown)),
                                      Text(DateFormat('dd/MM/yyyy (HH:mm)').format(new DateTime.fromMillisecondsSinceEpoch(lastOffres[index]["annonceTime"])), style: TextStyle(color: Colors.brown, fontSize: 10.0)),
                                    ],
                                  ),
                                  trailing: Icon(Icons.keyboard_arrow_right, color: Colors.black26, size: 30.0))
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Container(child: Text("Les offres"));
                },
              ),
            ),
            Container(
                padding: EdgeInsets.all(8),
                color: Color(0xFF766651),
                alignment: Alignment.center,
                child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: "Voir plus d'offres...",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if(lat != 0 && lng != 0) {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Offres(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'category': "Offre",
                                        'lat': lat,
                                        'lng': lng,
                                      },
                                    ),
                                  ),
                                );
                              }
                            }),
                    ]))
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Color(0xFFC78327),
              child: FutureBuilder(
                future: dbRef.child("Demande").once(),
                builder: (context, snapshot) {

                  List Demandes = [];
                  List lastDemandes = [];
                  if (snapshot.hasData && !snapshot.hasError) {
                    Demandes.clear();
                    DataSnapshot? dataValues = snapshot.data as DataSnapshot?;
                    Map<dynamic, dynamic> demandes = dataValues!.value;
                    demandes.forEach((key, values) {
                      if(values["annonceTime"]!=null) {
                        Demandes.add(values);
                      }
                    });
                    Demandes.sort((a, b) {
                      return b["annonceTime"].compareTo(a["annonceTime"]);
                    });
                    for(var i =0; i<5; i++) {
                      lastDemandes.add(Demandes[i]);
                    };
                    return new ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: lastDemandes.length,
                      itemBuilder: (BuildContext context, int index) {
                        var image;

                        return Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ListTile(
                                  onTap: () {
                                    if (user != null) {

                                      double dist = Geolocator.distanceBetween(lat, lng, lastDemandes[index]["lat"], lastDemandes[index]["lng"])/1000;
                                      String distance =(dist.round()).toString();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Details(),
                                          settings: RouteSettings(
                                            arguments: {
                                              'id': lastDemandes[index]["id"],
                                              'name': lastDemandes[index]["name"],
                                              'email': lastDemandes[index]["email"],
                                              'phone': lastDemandes[index]["phone"],
                                              'day': lastDemandes[index]["day"],
                                              'distance': distance,
                                              'annonceText': lastDemandes[index]["annonceText"],
                                              'descMessage': lastDemandes[index]["descMessage"],
                                              'annonceLink': lastDemandes[index]["annonceLink"],
                                              'r_mail': lastDemandes[index]["r_mail"],
                                              'r_phone': lastDemandes[index]["r_phone"],
                                              'rate': lastDemandes[index]["rate"],
                                              'sector': lastDemandes[index]["sector"],
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
                                  //leading: CircleAvatar(backgroundImage: AssetImage("images/liguey.png")),
                                  leading: FutureBuilder(
                                      future: _getimage(context, lastDemandes[index]["id"]),
                                      builder: (context, snapshot){
                                        if(!snapshot.data.toString().contains("http")){
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(backgroundImage: AssetImage('images/liguey.png')),
                                          );
                                        }else{
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(backgroundImage: NetworkImage(snapshot.data.toString())),
                                          );
                                        }
                                      }
                                  ),
                                  title: Text(lastDemandes[index]["name"],
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    children: <Widget>[
                                      Text(lastDemandes[index]["annonceText"], style: TextStyle(color: Colors.brown)),
                                      Text(DateFormat('dd/MM/yyyy (HH:mm)').format(new DateTime.fromMillisecondsSinceEpoch(lastDemandes[index]["annonceTime"])), style: TextStyle(color: Colors.brown, fontSize: 10.0)),
                                    ],
                                  ),
                                  trailing: Icon(Icons.keyboard_arrow_right, color: Colors.black26, size: 30.0))
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Container(child: Text("Les demandes"));

                },
              ),
            ),
            Container(
                padding: EdgeInsets.all(8),
                color: Color(0xFFC78327),
                alignment: Alignment.center,
                child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'Voir plus de jobbers...',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20.0,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if(lat != 0 && lng != 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Offres(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'category': "Demande",
                                        'lat': lat,
                                        'lng': lng,
                                      },
                                    ),
                                  ),
                                );
                              }
                            }),
                    ]))
            ),
            Container(
              height: 50,
              width: 250,
//              padding: const EdgeInsets.only(left:15.0,right: 15.0,top:15.0,bottom: 0),
              decoration: BoxDecoration(
                  color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  if (user != null) {
                    if(lat != 0 && lng != 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SendOffres(),
                          settings: RouteSettings(
                            arguments: {
                              'id': id,
                              'name': name,
                              'email': email,
                              'phone': phone,
                              'lat': lat,
                              'lng': lng,
                              'type': "Test",
                            },
                          ),
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                  }
                },
                child: Text(
                  'Devenir JOBBER',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _getLoc() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Can't get gurrent location"),
              content:const Text('Please make sure you enable GPS and try again'),
              actions: <Widget>[
                TextButton(child: Text('Ok'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    _currentPosition = await Geolocator.getCurrentPosition();
    lat = _currentPosition!.latitude;
    lng = _currentPosition!.longitude;
  }

//https://bleyldev.medium.com/how-to-show-photos-from-firestore-in-flutter-6adc1c0e405e
  Future<Widget> _getimage(BuildContext context, String imageName) async {
    Image im ;
    final value = await FireStorageService.loadImage(context, imageName);
    im =Image.network(
      value.toString(),
    );
    return value;
    /*
    await FireStorageService.loadImage(context, imageName).then((value) {
      if(value.toString().startsWith("http")){
        im = NetworkImage(value.toString());
      }else{
        im = AssetImage('images/liguey.png');
      }
    });
    return im;*/
  }
}

class FireStorageService extends ChangeNotifier {
  FireStorageService();
  static Future<dynamic> loadImage(BuildContext context, String image) async {
    return await FirebaseStorage.instance.ref().child("images").child(image).getDownloadURL();
  }
}