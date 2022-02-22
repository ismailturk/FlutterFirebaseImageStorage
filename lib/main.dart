import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //firebase i başlatmadan önce flutterin çalıştıgından emin olur
  await Firebase.initializeApp(); // firebase i başlatmaya yarar
  runApp(
      MaterialApp(debugShowCheckedModeBanner: false, home: Image_Firebase()));
}

class Image_Firebase extends StatefulWidget {
  const Image_Firebase({Key? key}) : super(key: key);

  @override
  _Image_FirebaseState createState() => _Image_FirebaseState();
}
//GLOBAL değişken alanı
var _imageHolder;
var imagePathHolder;


class _Image_FirebaseState extends State<Image_Firebase> {

  final takeImage = ImagePicker(); // galeriden resim seçecez


  // ------------------Galeriden resim seçtirecez

  Future imageFromGallery() async {
    final receviedImage = await takeImage.getImage(source: ImageSource.gallery);
    setState(() {
      if (receviedImage == null) {
        Fluttertoast.showToast(msg: "Empty file..");
      }
      else {
        _imageHolder = File(receviedImage.path);
        imagePathHolder = receviedImage.path;
      }
    });
  }


  // -------------------Kameradan resim seçtirecez

  Future imageFromCam() async {
    final receviedImage = await takeImage.getImage(source: ImageSource.camera);


    setState(() {
      if (receviedImage == null) {
        Fluttertoast.showToast(msg: "Empty file..");
      }
      else {
        _imageHolder = File(receviedImage.path);
        imagePathHolder = receviedImage.path;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("Image Firebase App"),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: _imageHolder == null
            ? Text("no picture selected")
            : uploadArea(),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: imageFromGallery, child: Icon(Icons.photo),),
          FloatingActionButton(
            onPressed: imageFromCam, child: Icon(Icons.camera_alt),),
          FloatingActionButton(onPressed: () {
            takeUrl();
          }, child: Icon(Icons.link),),
        ],
      ),
    );
  }
}

Future<void> takeUrl() async{
  var url =await storage.FirebaseStorage.instance.ref().child(imagePathHolder).getDownloadURL();
  Fluttertoast.showToast(msg: url);
  print(url);
}


Widget uploadArea() {
  return Column(
    children: [
      Image.file(_imageHolder!),
      ElevatedButton(onPressed: () {
        uploadImage();
      }, child: Text("Upload Image to Database"))
    ],
  );
}

Future uploadImage() async {
  //depolama yolu
  storage.Reference storagePath = storage.FirebaseStorage.instance.ref().child(imagePathHolder);


  // resmi gönderme kısmı

    storagePath.putFile(_imageHolder);
    Fluttertoast.showToast(msg: "Image Added");

  
}
