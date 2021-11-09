
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_liguey/translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

//https://www.kindacode.com/article/flutter-firebase-storage/

class SeeCV extends StatefulWidget {
  @override
  _SeeCVState createState() => _SeeCVState();
}

class _SeeCVState extends State<SeeCV> {
  String url= "";
  String name= "";

  @override
  Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    url = arguments['url'];
    name = arguments['name'];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Color(0xFFE0BF92),
      ),
      body: Container(
        child:
        SfPdfViewer.network(url),
      ),
    );
  }
}