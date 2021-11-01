import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//https://github.com/theandroidclassroom/flutter_realtime_database/blob/master/lib/screens/contacts.dart

class SendOffres extends StatefulWidget {

  @override
  _SendOffresState createState() => _SendOffresState();
}

class _SendOffresState extends State<SendOffres> {

  DateTime annonceEnd = DateTime.now();
  String annonceLink="Nolink";
  String annonceText = "";
  late DateTime annonceTime;
  String annonceOrder = "";
  String annonceType = "";
  String descMessage = "";
  String email = "";
  String id = "";
  double lat = 0;
  double lng = 0;
  String name = "";
  String phone = "";
  String r_mail = "YES";
  String r_phone = "YES";
  double rate = 0;
  String sector = "";
  bool _enabled = false;
  String link = "";
  String linktext = "";
  String Langue = "";
  String publier = "";
  String phoneyesno = "";
  String emailyesno = "";
  String profil = "";
  String lieu = "";
  String message = "";
  String nombre = "";
  String endday = "";
  String TLieu = "";
  String TNombre = "";

  late UserModel annonce;
  var categories = [""];
  late DatabaseReference dbRef;
  TextEditingController nController = new TextEditingController();
  TextEditingController rController = new TextEditingController();
  TextEditingController dController = new TextEditingController();
  TextEditingController lController = new TextEditingController();
  TextEditingController eController = new TextEditingController();
  TextEditingController lkController = new TextEditingController();
  bool pvalue = true;
  bool evalue = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = FirebaseDatabase.instance.reference();
    Langue = Intl.systemLocale;
  }

  void _success(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    id = arguments['id'];
    name = arguments['name'];
    email = arguments['email'];
    phone = arguments['phone'];
    lat = arguments['lat'];
    lng = arguments['lng'];
    annonceType = arguments['type'];

    if(Langue != "fr"){
      publier = "Publier";
      phoneyesno = "Afficher mon téléphone ?";
      emailyesno = "Afficher mon email ?";
      nombre = "Nombre de places";
      profil = "Résumé (exp: Je cherche 2 vendeurs)";
      message = "La mission en quelques mots";
      lieu  = "Le lieu de l'emploi";
      endday = "Date limite de candidature";
      linktext = "Mettez ici un lien https si nécessaire";
      TLieu = "Lieu : ";
      TNombre = "Nombre : ";
    } else {
      publier = "Publish";
      phoneyesno = "Show my phone ?";
      emailyesno = "Show my email ?";
      nombre = "Number of posts";
      profil = "Summary (e.g.: I'm looking for 2 sellers)";
      message = "A description message for the job";
      lieu = "The location of the job";
      endday = "Application deadline";
      linktext = "Put a https link here if necessary";
      TLieu = "Location : ";
      TNombre = "Number : ";
    }

    if(annonceType == "Test"){
      _enabled = true;
      link = linktext;
    }

    Future pickDate(BuildContext context) async {
      final newDate = await showDatePicker(
        context: context,
        initialDate: annonceEnd,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 5),
      );

      if (newDate == null) return;

      setState(() => annonceEnd = newDate);
    }

    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Liguey'),
            backgroundColor: Color(0xFFE0BF92)
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                child: Center(
                  child: Text(
                    "Bienvenue sur LIGUEY,\n\ninscrivez-vous pour accéder aux annonces",
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: rController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: profil,
                    hintText: profil,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: dController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: message,
                    hintText: message,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: lController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: lieu,
                    hintText: lieu,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  enabled:_enabled,
                  controller: nController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: nombre,
                    hintText: nombre,
                  ),
                  textInputAction: TextInputAction.done, // Hides the keyboard.
                  keyboardType: TextInputType.number,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                child: TextField(
                  onTap: () {
                    pickDate(context);
                  },
                  enabled:_enabled,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: endday,
                    hintText: DateFormat('dd/MM/yyyy').format(annonceEnd),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  enabled:_enabled,
                  controller: lkController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Link',
                    hintText: link,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: CheckboxListTile(
                  title: Text(phoneyesno),
                  value: pvalue,
                  onChanged: (bool? value) {
                    setState(() {
                      pvalue = value!;
                      if(pvalue == true){
                        r_phone = "NO";
                      }
                    });
                  },
                  secondary: const Icon(Icons.phone),
                )
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 0, bottom: 0),
                  //padding: EdgeInsets.symmetric(horizontal: 15),
                  child: CheckboxListTile(
                    title: Text(emailyesno),
                    value: evalue,
                    onChanged: (bool? value) {
                      setState(() {
                        evalue = value!;
                        if(evalue == true){
                          r_mail = "NO";
                        }
                      });
                    },
                    secondary: const Icon(Icons.email_outlined),
                  )
              ),
              Container(
                height: 50,
                width: 250,
                decoration: BoxDecoration(
                    color: Color(0xFFE0BF92),
                    borderRadius: BorderRadius.circular(20)),
                child: TextButton(
                  onPressed: () {
                    final String number = nController.text.trim();
                    final String title = rController.text.trim();
                    final String description = dController.text.trim();
                    final String location = lController.text.trim();
                    final String alink = lkController.text.trim();

                    if (!alink.isEmpty) {
                      annonceLink = alink;
                    }

                    if (title.isEmpty) {
                      print("Password is Empty");
                    } else {
                      if (description.isEmpty) {
                        print("Name is Empty");
                      } else {
                        if (location.isEmpty) {
                          print("Surname is Empty");
                        } else {
                            //Envoi vers Firebase
                            annonceTime = new DateTime.now();

                            if(annonceType == "Test") {
                              annonceOrder = "-" + annonceTime.toString();
                              annonceText = title + ".\n" + TLieu + location + "\n"+ TNombre + number;
                            }else{
                              annonceOrder = "O";
                              annonceText = title + ".\n" + TLieu + location;
                            }

                            dbRef.child(annonceType).push().set({
                              "name": name,
                              "annonceEnd": annonceEnd,
                              "annonceLink": annonceLink,
                              "annonceOrder": annonceOrder,
                              "annonceText": annonceText,
                              "annonceTime": annonceTime,
                              "annonceType": annonceType,
                              "day": DateFormat('dd-MM-yyyy').format(new DateTime.now()),
                              "descMessage": description,
                              "email": email,
                              "id": id,
                              "lat": lat,
                              "lng": lng,
                              "phone": phone,
                              "r_mail": r_mail,
                              "r_phone": r_phone,
                              "rate": rate,
                              "sector": sector,
                            }).whenComplete(() => _success(context));

                        }
                      }
                    }
                  },
                  child: Text(publier,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}