import 'package:flutter/material.dart';

class Annonce extends StatelessWidget {
  const Annonce({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                ),
                Text(
                  "Titre de l'annonce",
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          Icon(
            Icons.star,
            color: Colors.red[500],

          ),
          const Text('41'),
        ],
      ),
    );

    Color color = Theme
        .of(context)
        .primaryColor;

    Widget buttonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumn(color, Icons.call, 'CALL'),
        _buildButtonColumn(color, Icons.email, 'EMAIL'),
        _buildButtonColumn(color, Icons.location_pin, 'DISTANCE'),
      ],
    );

    Widget textSection = const Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        "Bienvenue sur Liguey, l'application qui vous aide dans votre recherche d'emploi",
        softWrap: true,
      ),
    );

    return MaterialApp(
      title: 'Liguey',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Liguey'),
        ),
        body: ListView(
          children: [
            Image.asset(
              'images/liguey.png',
              width: 600,
              height: 240,
              fit: BoxFit.cover,
            ),
            titleSection,
            buttonSection,
            textSection,
          ],
        ),
      ),
    );
  }

  Column _buildButtonColumn(Color color, IconData icon, String label) {
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
              )
          ),
        ),
      ],
    );
  }
}