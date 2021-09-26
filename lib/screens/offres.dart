import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter_liguey/screens/details.dart';
import 'package:flutter_liguey/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';

class Offres extends StatefulWidget {

  @override
  _OffresState createState() => _OffresState();
}

class _OffresState extends State<Offres> {
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

  String day = "";

  @override
  Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final dbRef = FirebaseDatabase.instance.reference().child(arguments['category']);

    final user = context.watch<User>();
    var currentSelectedValue;
    const categories = ["Vente", "Menage", "Cuisine"];

    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liguey'),
          backgroundColor: Color(0xFFE0BF92)
        ),
        body: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              color: Color(0xFFE0BF92),
              padding: EdgeInsets.all(8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text("Selectionner une catégorie"),
                  value: currentSelectedValue,
                  isDense: true,
                  onChanged: (newValue) {
                    setState(() {
                      currentSelectedValue = newValue;
                    });
                    print(currentSelectedValue);
                  },
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              color: Color(0xFF766651),
              child: StreamBuilder(
                stream: dbRef.onValue,
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
                  return Container(child: Text("Les offres"));
                },
              ),
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