import 'package:flutter/material.dart';

class Details extends StatefulWidget {

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {

  var name, annonceText, descMessage, email, phone, rate, distance;

  @override
  Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    name = arguments['name'];
    email = arguments['email'];
    phone = arguments['phone'];
    rate = arguments['rate'];
    distance = arguments['distance'];
    annonceText = arguments['annonceText'];
    descMessage = arguments['descMessage'];

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
        _buildButtonColumn(color, Icons.call, 'CALL', onPressed: () {}),
        _buildButtonColumn(color, Icons.mail, 'EMAIL', onPressed: () {}),
        _buildButtonColumn(color, Icons.location_pin, "Dist: "+distance+" km", onPressed: () {}),
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
            Image.asset(
              'images/liguey.png',
              width: 400,
              height: 240,
              fit: BoxFit.fill,
            ),
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
}
