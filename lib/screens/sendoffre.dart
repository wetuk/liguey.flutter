import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liguey/services/auth_services.dart';
import 'package:flutter_liguey/translations.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';

//https://github.com/theandroidclassroom/flutter_realtime_database/blob/master/lib/screens/contacts.dart

class SendOffres extends StatefulWidget {

  @override
  _SendOffresState createState() => _SendOffresState();
}

class _SendOffresState extends State<SendOffres> {

  DateTime annonceEnd = DateTime.now();
  int end = 0;
  String annonceLink="Nolink";
  String annonceText = "";
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
  String date = "";

  late UserModel annonce;
  late DatabaseReference dbRef;
  TextEditingController nController = new TextEditingController();
  TextEditingController rController = new TextEditingController();
  TextEditingController dController = new TextEditingController();
  TextEditingController lController = new TextEditingController();
  TextEditingController eController = new TextEditingController();
  TextEditingController lkController = new TextEditingController();
  TextEditingController endController = new TextEditingController();

  bool pvalue = true;
  bool evalue = true;
  String dropdownValue = '';
  List<String> sectorlist = [];
  String category = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbRef = FirebaseDatabase.instance.reference();
    Langue = Intl.systemLocale;
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
    id = arguments['id'];
    name = arguments['name'];
    email = arguments['email'];
    phone = arguments['phone'];
    lat = arguments['lat'];
    lng = arguments['lng'];
    annonceType = arguments['type'];
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

    if(annonceType == "Offre"){
      _enabled = true;
      link = Translations.of(context, 'linktext');
      profil = Translations.of(context, 'profiljob');
      message = Translations.of(context, 'messagejob');
    }else{
      profil = Translations.of(context, 'profiljobber');
      message = Translations.of(context, 'messagejobber');
    }

    Future pickDate(BuildContext context) async {
      final newDate = await showDatePicker(
        context: context,
        initialDate: annonceEnd,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 5),
      );

      if (newDate == null) return;

      setState(() {
        annonceEnd = newDate;
        end = newDate.millisecondsSinceEpoch;
        endController.text = DateFormat('dd/MM/yyyy').format(annonceEnd);
      });
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
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: rController,
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: profil,
                    hintText: profil,
                  ),
                  //textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: dController,
                  keyboardType: TextInputType.multiline,
                  minLines: null,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: message,
                    hintText: message,
                  ),
                  //textInputAction: TextInputAction.next,
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
                    labelText: Translations.of(context, 'lieu'),
                    hintText: Translations.of(context, 'lieu'),
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: Visibility(
                  visible: _enabled,
                  child: TextField(
                    enabled:_enabled,
                    controller: nController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Translations.of(context, 'nombre'),
                      hintText: Translations.of(context, 'nombre'),
                    ),
                    textInputAction: TextInputAction.done, // Hides the keyboard.
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
                child: Visibility(
                  visible: _enabled,
                  child: TextField(
                    onTap: () {
                      pickDate(context);
                    },
                    enabled:_enabled,
                    controller: endController, //editing controller of this TextField
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Translations.of(context, 'endday'),
                      hintText: DateFormat('dd/MM/yyyy').format(annonceEnd),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5.0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: Visibility(
                  visible: _enabled,
                  child: TextField(
                    enabled:_enabled,
                    controller: lkController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: link,
                      hintText: link,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 0, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: Visibility(
                  visible: _enabled,
                  child: CheckboxListTile(
                    title: Text(Translations.of(context, 'phoneyesno')),
                    value: pvalue,
                    onChanged: (bool? value) {
                      setState(() {
                        pvalue = value!;
                        if(pvalue != true){
                          r_phone = "NO";
                        }else{
                          r_phone = "YES";
                        }
                      });
                    },
                    secondary: const Icon(Icons.phone),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 0, bottom: 0),
                child: Visibility(
                  visible: _enabled,
                  child: CheckboxListTile(
                    title: Text(Translations.of(context, 'emailyesno')),
                    value: evalue,
                    onChanged: (bool? value) {
                      setState(() {
                        evalue = value!;
                        if(evalue != true){
                          r_mail = "NO";
                        }else{
                          r_mail = "YES";
                        }
                      });
                    },
                    secondary: const Icon(Icons.email_outlined),
                  ),
                ),
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
                      print("Title is Empty");
                    } else {
                      if (description.isEmpty) {
                        print("Description is Empty");
                      } else {
                        if (location.isEmpty) {
                          print("Location is Empty");
                        } else {
                            //Envoi vers Firebase
                            date = DateFormat('dd-MM-yyyy').format(new DateTime.now());
                            if(annonceType == "Offre") {
                              annonceText = title + ".\n" + Translations.of(context, 'TLieu') + location + "\n"+ Translations.of(context, 'TNombre') + number;
                            }else{
                              annonceText = title + ".\n" + Translations.of(context, 'TLieu') + location;
                            }

                            context.read<AuthService>().send(
                             name,
                             end,
                             annonceLink,
                             annonceText,
                             annonceType,
                             date,
                             description,
                             email,
                             id,
                             lat,
                             lng,
                             phone,
                             r_mail,
                             r_phone,
                             rate,
                             sector,
                            ).whenComplete(() => _success(context));
                        }
                      }
                    }
                  },
                  child: Text(Translations.of(context, 'publier'),
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
}