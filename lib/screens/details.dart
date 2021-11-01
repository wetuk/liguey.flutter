import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Details extends StatefulWidget {

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  var name, annonceText, descMessage, email, phone, rate, distance, image, uid, url, Aimage;

  @override
  void initState() {
    // TODO: implement initState
    //_getImage();
    super.initState();
  }
/*
  _getImage() async {

    url = await FirebaseStorage.instance.ref().child("images").child("00o1deOAKLfAnHZW0BDgPYvis182.*").getDownloadURL().toString();
    if( url!=null) {
      image = Image.network(
        url,
        width: 400,
        height: 240,
        fit: BoxFit.fill,
      );
    }else{
      image = Image.asset(
        'images/liguey.png',
        width: 400,
        height: 240,
        fit: BoxFit.fill,
      );
    }
  }

  */

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

    Widget imageSection = Container(
      padding: EdgeInsets.all(8),
      color: Color(0xFFC78327),

      child: FutureBuilder(
          future: _getimage(context, uid),
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
          Icon(
            Icons.star,
            color: Colors.red[500],
          ),
          Text(rate.toString()),
        ],
      ),
    );

    Color color = Theme.of(context).primaryColor;

    Widget buttonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(color, Icons.call, 'CALL', onPressed: () {launch("tel:"+ phone);}),
        _buildButtonColumn(color, Icons.mail, 'EMAIL', onPressed: () {}),
        _buildButtonColumn(color, Icons.location_pin, "Dist: "+distance+" km", onPressed: () {launch("tel:"+ phone);}),
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

  Column _buildButtonColumn(Color color, IconData icon, String label, {Null Function()? onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
//https://bleyldev.medium.com/how-to-show-photos-from-firestore-in-flutter-6adc1c0e405e
  Future<Widget> _getimage(BuildContext context, String imageName) async {
    await FireStorageService.loadImage(context, imageName).then((value) {

      if(value.startsWith("http")){
        image = Image.network(value, fit: BoxFit.fill);
      }else{
        image = Image.asset('images/liguey.png', fit: BoxFit.fill);
      }
    });
    return image;
  }
}

class FireStorageService extends ChangeNotifier {
  static Future<dynamic> loadImage(BuildContext context, String Image) async {
    String url = await FirebaseStorage.instance.ref().child("images").child(Image).getDownloadURL();
    if(url.toString().startsWith("http")){
      return url;
    }else{
     return null;
    }
  }
}