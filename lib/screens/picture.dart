import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_liguey/translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_progress_indicator_ns/liquid_progress_indicator.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';

//https://www.kindacode.com/article/flutter-firebase-storage/

class Picture extends StatefulWidget {
  @override
  _PictureState createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  FirebaseStorage storage = FirebaseStorage.instance;
  var uid, name;

  double progress = 0.0;
  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource, String imageName, String userName) async {
    final picker = ImagePicker();
    PickedFile? pickedImage;
    try {
      pickedImage = await picker.getImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      File imageFile = File(pickedImage!.path);

      try {
        // Uploading the selected image with some custom meta data
        await storage.ref().child("images").child(imageName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': userName,
            })).snapshotEvents.listen((event) {
              setState(() {
                progress = ((event.bytesTransferred.toDouble()/event.totalBytes.toDouble())*100).roundToDouble();
              });
        });

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        print(error);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<String> _loadImage(String image) async {
    String  result = await storage.ref().child("images").child(image).getDownloadURL();
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
        builder: (context) => Picture(),
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
        title: Text(Translations.of(context, 'picture')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                    onPressed: () => _upload('camera', uid, name),
                    icon: Icon(Icons.camera),
                    label: Text('camera')),
                ElevatedButton.icon(
                    onPressed: () => _upload('gallery', uid, name),
                    icon: Icon(Icons.library_add),
                    label: Text('Gallery')),
              ],
            ),
            Container(
              child: FutureBuilder(
                future: _loadImage(uid),
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if(snapshot.data.toString() != "null") {
                      return SingleChildScrollView(
                          child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Center(
                                    child:   Container(
                                      width: 200,
                                      height: 200,
                                      child: Image.network(snapshot.data.toString(),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Center(
                                    child:  Container(
                                      child: IconButton(
                                        onPressed: () => _delete(uid).whenComplete(() => _success(context)),
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                          )
                      );
                    }else{
                      if (progress == 0.0){
                        return SingleChildScrollView(
                            child: Container(
                                width: 200,
                                height: 200,
                                child: Image.asset('images/liguey.png', fit: BoxFit.fill)
                            )
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