import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_liguey/main.dart';
import 'package:flutter_liguey/translations.dart';
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

      final String fileName = path.basename(pickedImage!.path);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        await storage.ref().child("test").child(imageName).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'uploaded_by': userName,
            }));

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        print(error);
      }
    } catch (err) {
      print(err);
    }
  }

  // Retriew the uploaded images
  // This function is called when the app launches for the first time or when an image is uploaded or deleted
  Future<String> _loadImage(String image) async {

    String  result = await storage.ref().child("test").child(image).getDownloadURL();
    return result;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref().child("test").child(ref).delete();
    // Rebuild the UI
    setState(() {});
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
                    return Container(
                        child: Image.network(snapshot.data.toString(), fit: BoxFit.fill)
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(color: Color(0xFFE0BF92), borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyApp(),
                    ),
                  );
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}