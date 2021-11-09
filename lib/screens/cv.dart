
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_liguey/screens/seecv.dart';
import 'package:flutter_liguey/translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:path/path.dart' as path;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

//https://www.kindacode.com/article/flutter-firebase-storage/

class CV extends StatefulWidget {
  @override
  _CVState createState() => _CVState();
}

class _CVState extends State<CV> {
  FirebaseStorage storage = FirebaseStorage.instance;
  var uid, name;

  double progress = 0.0;
  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String cvName, String userName) async {

    try {

      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File? file = File(result.files.single.path.toString());

        await storage.ref().child("cv").child(cvName).putFile(file).snapshotEvents.listen((event) {
          setState(() {
            progress = ((event.bytesTransferred.toDouble()/event.totalBytes.toDouble())*100).roundToDouble();
          });
        });
      }
    } catch (err) {
      print(err);
    }
  }

  Future<String> _loadCV(String cvName) async {
    String  result = await storage.ref().child("cv").child(cvName).getDownloadURL();
    return result;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String imageFileUrl) async {
    var fileUrl = Uri.decodeFull(path.basename(imageFileUrl)).replaceAll(new RegExp(r'(\?alt).*'), '');
    await storage.ref().child("images").child(fileUrl).delete();
  }

  void _success(BuildContext context) async {
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => CV(),
        settings: RouteSettings(
          arguments: {
            'id': uid,
            'name': name,
          },
        ),
      ),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    uid = arguments['id'];
    name = arguments['name'];

    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.of(context, 'cv')),
        backgroundColor: Color(0xFFE0BF92),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                    onPressed: () => _upload(uid, name),
                    icon: Icon(Icons.library_add, color: Color(0xFFE0BF92),),
                    label: Text('Gallery'),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              child: FutureBuilder(
                future: _loadCV(uid),
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if(snapshot.data.toString() != "null") {
                      return Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SeeCV(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'url': snapshot.data.toString(),
                                        'name': name,
                                      },
                                    ),
                                  ),
                                );

                          },
                          child: Text(
                            Translations.of(context, 'seecv'),
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                          //child: SfPdfViewer.network(snapshot.data.toString()),
                      );
                    }else{
                      if (progress == 0.0){
                        return Container(
                          alignment: Alignment.center,
                          child: Text("Déposer un CV"),
                        );
                      }else{
                        return Container(
                          height: 200,
                          width: 200,
                          child: LiquidCircularProgressIndicator(
                            value: progress/100,
                            valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
                            backgroundColor: Colors.white,
                            direction: Axis.vertical,
                            center: Text(
                              "$progress%",
                              style: GoogleFonts.poppins(
                                  color: Colors.black87, fontSize: 25.0),
                            ), borderWidth: 50, borderColor: Colors.white,
                          ),
                        );
                      }
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}