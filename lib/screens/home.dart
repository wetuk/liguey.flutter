import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter_liguey/screens/details.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late UserModel annonce;
  late DatabaseReference Ref;
  late Position _currentPosition;
  late String _currentAddress;
  late double lat;
  late double lng;

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase.instance;
    Ref = database.reference();
    _getCurrentLocation();
  }

  _getCurrentLocation() {
    Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best, forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        lat = _currentPosition.latitude;
        lng = _currentPosition.longitude;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude,
          _currentPosition.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future <Home?> _signOut()  async{
    await FirebaseAuth.instance.signOut();
    return null;
  }

  User? user = FirebaseAuth.instance.currentUser;
  String Uid = FirebaseAuth.instance.currentUser!.uid;

  final dbRef = FirebaseDatabase.instance
      .reference();

  List lastOffres = [];
  List lastDemandes = [];

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
            Text(lat.toString() + "Texte" + lng.toString()+"\n"+_currentAddress),
            Container(
              padding: EdgeInsets.all(8),
              color: Color(0xFFE0BF92),
              child: StreamBuilder(
                stream: dbRef.child("Offre").onValue,
                builder: (context, AsyncSnapshot<Event> snapshot) {
                  if (snapshot.hasData) {
                    lastOffres.clear();
                    DataSnapshot dataValues = snapshot.data!.snapshot;
                    Map<dynamic, dynamic> values = dataValues.value;
                    int i=0;
                    values.forEach((key, values) {
                      i++;
                      if(i < 5) {
                        lastOffres.add(values);
                      }
                    });
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

                                  },
                                  title: Text(lastOffres[index]["name"]),
                                  subtitle: Text(lastOffres[index]["annonceText"]),
                                  leading: CircleAvatar(backgroundImage: AssetImage("images/welcome_liguey.jpg")),
                                  trailing: Icon(Icons.star)
                              ),
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
              color: Color(0xFFE0BF92),
              child: StreamBuilder(
                stream: dbRef.child("Demande").onValue,
                builder: (context, AsyncSnapshot<Event> snapshot) {
                  if (snapshot.hasData) {
                    lastDemandes.clear();
                    DataSnapshot dataValues = snapshot.data!.snapshot;
                    Map<dynamic, dynamic> values = dataValues.value;
                    int j=0;
                    values.forEach((key, values) {
                      j++;
                      if(j < 5) {
                        lastDemandes.add(values);
                      }
                    });
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Details(),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(

                                          builder: (context) => Login(),
                                        ),
                                      );                                    }
                                  },
                                  title: Text(lastDemandes[index]["name"]),
                                  subtitle: Text(lastDemandes[index]["annonceText"]),
                                  leading: CircleAvatar(backgroundImage: AssetImage("images/welcome_liguey.jpg")),
                                  trailing: Icon(Icons.star)
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Container(child: Text("Les Demandes"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}