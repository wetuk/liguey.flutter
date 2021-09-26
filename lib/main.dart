import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter_liguey/screens/details.dart';
import 'package:flutter_liguey/screens/home.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter_liguey/screens/offres.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

//Integration Wordpress
// https://ichi.pro/fr/comment-integrer-votre-application-flutter-dans-wordpress-225846033883803
//https://www.youtube.com/playlist?list=PLjxrf2q8roU23XGwz3Km7sQZFTdB996iG


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
        //home: AuthWrapper(),
      ),
    );
  }
}
//
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    if (user != null) {
      return Home();
    } else {
      return Login();
    }
  }
}

class MyLocation extends StatefulWidget {
  @override
  _MyLocationState createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  String _address = "";
  String _dateTime="";
  Location location = Location();
  LocationData _currentPosition = null as LocationData;

  late UserModel annonce;
  late DatabaseReference Ref;
  late double lat=0;
  late double lng=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoc();
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();
    if (user != null) {
      log = "Déconnexion";
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
          children: [
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
              padding: EdgeInsets.all(8),
              color: Color(0xFF766651),
              child: StreamBuilder(
                stream: dbRef.child("Offre").onValue,
                builder: (context, AsyncSnapshot<Event> snapshot) {

                  List Offres = [];
                  List lastOffres = [];
                  if (snapshot.hasData && !snapshot.hasError) {
                    Offres.clear();
                    DataSnapshot dataValues = snapshot.data!.snapshot;
                    Map<dynamic, dynamic> offres = dataValues.value;
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
                    return new ListView.builder(
                      shrinkWrap: true,
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
                              leading: CircleAvatar(backgroundImage: AssetImage("images/liguey.png")),
                              title: Text(lastOffres[index]["name"],
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                alignment: Alignment.center,
                //color: Color(0xFF766651),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: 'Voir toutes les offres',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Offres(),
                              settings: RouteSettings(
                                arguments: {
                                  'category': "Offre",
                                },
                              ),
                            ),
                          );
                        }),
              ]))
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Color(0xFFC78327),
              child: StreamBuilder(
                stream: dbRef.child("Demande").onValue,
                builder: (context, AsyncSnapshot<Event> snapshot) {
                  List Demandes = [];
                  List lastDemandes = [];
                  if (snapshot.hasData && !snapshot.hasError) {
                    Demandes.clear();
                    DataSnapshot dataValues = snapshot.data!.snapshot;
                    Map<dynamic, dynamic> demandes = dataValues.value;
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
                      itemCount: lastDemandes.length,
                      itemBuilder: (BuildContext context, int index) {
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
                                  leading: CircleAvatar(backgroundImage: AssetImage("images/liguey.png")),
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
                //color: Color(0xFF766651),
                alignment: Alignment.center,
                child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'Voir toutes les demandes',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Offres(),
                                  settings: RouteSettings(
                                    arguments: {
                                      'category': "Demande",
                                    },
                                  ),
                                ),
                              );
                            }),
                    ]))
            ),
          ],
        ),
      ),
    );
  }

  getLoc() async{
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();

    location.onLocationChanged.listen((LocationData currentLocation) {
      //print("${currentLocation.longitude} : ${currentLocation.longitude}");
      setState(() {
        _currentPosition = currentLocation;
        double? lat = _currentPosition.latitude;
        double? lng = _currentPosition.longitude;

        DateTime now = DateTime.now();
        _dateTime = DateFormat('EEE d MMM kk:mm:ss ').format(now);
        _getAddress(lat!,lng!)
            .then((value) {
          setState(() {
            _address = "${value.first.addressLine}";
          });
        });
      });
    });
  }

  Future<List<Address>> _getAddress(double lat, double lng) async {
    final coordinates = new Coordinates(lat, lng);
    List<Address> add =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return add;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('_address', _address));
  }

}