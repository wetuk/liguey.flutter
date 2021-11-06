import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter_liguey/screens/details.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter_liguey/screens/offres.dart';
import 'package:flutter_liguey/screens/profil.dart';
import 'package:flutter_liguey/screens/sendoffre.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'translations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
        localizationsDelegates: [
          TranslationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('fr', ''),
        ],
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
  Position? _currentPosition;
  late UserModel annonce;
  late DatabaseReference Ref;
  double lat=0;
  double lng=0;
  String sectors = '';
  final dbRef = FirebaseDatabase.instance.reference();

  String log ="";
  String day = "";
  String id = "";
  String name = "";
  String email = "";
  String phone = "";

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getLoc();
    _getCategories(Translations.of(context, 'langue')).then((val){
      sectors = val;
    });
  }

  Future <MyApp?> _signOut()  async{
    await FirebaseAuth.instance.signOut();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user != null) {
      log = Translations.of(context, 'profil');
      id = user.uid;
      email = user.email!;
      _getUser(id);
    }else{
      log = Translations.of(context, 'connexion');
    }
    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Liguey"),
          backgroundColor: Color(0xFFE0BF92),
          actions: <Widget> [
            TextButton.icon(
                icon: Icon(Icons.person, color: Colors.black),
                label: Text(log, style: TextStyle(color: Colors.black),
                ),
                onPressed: () async{
                  if (user != null) {
                    //await _signOut();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profil(),
                        settings: RouteSettings(
                          arguments: {
                            'id': id,
                            'name': name,
                            'email': email,
                            'phone': phone,
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
                }
            )
          ],
        ),
        body: SingleChildScrollView(
          child : Column(
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
                    //fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
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
                                'type': "Offre",
                                'sectors': sectors,
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
                    Translations.of(context, 'postjob'),
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
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
                      DataSnapshot dataValues = snapshot.data as DataSnapshot;
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
                                        future: _loadImage(lastOffres[index]["id"]),
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
                    return Container(child: Text(Translations.of(context, 'jobs')));
                  },
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(top:15.0,bottom: 30.0),
                  color: Color(0xFF766651),
                  alignment: Alignment.center,
                  child: RichText(
                      text: TextSpan(children: [
                        WidgetSpan(
                          child: Icon(Icons.arrow_forward, size: 24, color: Colors.blue,
                          ),
                        ),
                        TextSpan(
                            text: Translations.of(context, 'alljobs'),
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20.0,
                              decoration: TextDecoration.underline,
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
                                          'sectors': sectors,
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
                      DataSnapshot dataValues = snapshot.data as DataSnapshot;
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
                                    leading: FutureBuilder(
                                        future: _loadImage(lastDemandes[index]["id"]),
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
                    return Container(child: Text(Translations.of(context, 'jobbers')));
                  },
                ),
              ),
              Container(
                  padding: const EdgeInsets.only(top:15.0,bottom: 30.0),
                  color: Color(0xFFC78327),
                  alignment: Alignment.center,
                  child: RichText(
                      text: TextSpan(children: [
                        WidgetSpan(
                          child: Icon(Icons.arrow_forward, size: 24, color: Colors.blueAccent,),
                        ),
                        TextSpan(
                            text: Translations.of(context, 'alljobbers'),
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20.0,
                              decoration: TextDecoration.underline,
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
                                          'sectors': sectors,
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }),
                      ]))
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
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
                                'type': "Demande",
                                'sectors': sectors,
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
                    Translations.of(context, 'postjobber'),
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _getCategories(String lang) async {
    String result = (await dbRef.child("JobCategories").child(lang).once()).value;
    return result;
  }

  Future<String> _getUser(String uid) async {

    return dbRef.child("Users").child(uid).once().then((DataSnapshot snap) {
      name = snap.value['userName'].toString();
      phone = snap.value['userPhone'].toString();

      return name;

    });
  }

  Future _getLoc() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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

  Future<String> _loadImage(String image) async {
    String result = await FirebaseStorage.instance.ref().child("images").child(image).getDownloadURL();
    return result;
  }
}
