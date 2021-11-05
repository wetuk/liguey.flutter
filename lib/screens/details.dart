import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Details extends StatefulWidget {

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  var name, annonceText, descMessage, email, phone, rate, distance, image, uid, cv;
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

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    uid = arguments['id'];
    name = arguments['name'];
    email = arguments['email'];
    phone = arguments['phone'];
    rate = arguments['rate'];
    distance = arguments['distance'];
    annonceText = arguments['annonceText'];
    descMessage = arguments['descMessage'];
    if(arguments['r_mail']! == "NO"){
      r_mail = false;
    }
    if(arguments['r_phone']! == "NO"){
      r_phone = false;
    }

    Widget imageSection = Container(
      padding: EdgeInsets.all(8),
      color: Color(0xFFC78327),

      child: FutureBuilder(
          future: _getImage(context, uid),
          builder: (context, snapshot){
            return Container(
              width: 400,
              height: 240,
              child: image
            );
          }
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
          Visibility(
            child: FutureBuilder(
                future: _getCV(context, uid),
                builder: (context, snapshot){
                  return Container(
                      child: Text("Mon CV")
                  );
                }
            ),
            visible: vis,
          ),
        ],
      ),
    );

    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(r_phone, color, Icons.call, 'CALL'),
        _buildButtonColumn(r_mail,color, Icons.mail, 'EMAIL'),
        _buildButtonColumn(true, color, Icons.location_pin, "Dist: "+distance+" km"),
      ],
    );

    Widget textSection = Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        descMessage,
        softWrap: true,
      ),
    );

    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liguey'),
          backgroundColor: Color(0xFFE0BF92),
        ),
        body: ListView(
          children: [
            imageSection,
            titleSection,
            buttonSection,
            textSection,
          ],
        ),
      ),
    );
  }

  Widget _buildButtonColumn(bool visible, Color color, IconData icon, String label) {
    return GestureDetector(
      onTap: (){
        if(label == "CALL"){
          launch("tel:"+ phone);
        }else if (label == "EMAIL"){
          launch("mailto:"+ email +",wetuk.sa@gmail.com");
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Visibility(
            child:Icon(icon, color: color),
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
  Future<Widget> _getImage(BuildContext context, String imageName) async {
    await ImageService.loadImage(context, imageName).then((value) {

      if(value.startsWith("http")){
        image = Image.network(value, fit: BoxFit.fill);
      }else{
        image = Image.asset('images/liguey.png', fit: BoxFit.fill);
      }
    });
    return image;
  }

  Future<Widget> _getCV(BuildContext context, String cvName) async {
    await CVService.loadImage(context, cvName)
        .then((value) {
          if(value.startsWith("http")){
            cv = value;
            vis = true;
          }
        });
    return cv;
  }
}

class ImageService extends ChangeNotifier {
  static Future<dynamic> loadImage(BuildContext context, String userid) async {
    String url = await FirebaseStorage.instance.ref().child("images").child(userid).getDownloadURL();
    if(url.toString().startsWith("http")){
      return url;
    }else{
     return null;
    }
  }
}

class CVService extends ChangeNotifier {
  static Future<dynamic> loadImage(BuildContext context, String userid) async {
    String url = await FirebaseStorage.instance.ref().child("cv").child(userid).getDownloadURL();
    if(url.toString().startsWith("http")){
      return url;
    }else{
      return null;
    }
  }
}