import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
  home: MyApp(),
));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading = false;
  var a;
  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
        print(a);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
//    print();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachable Machine Learning'),
      ),
      body: _loading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null ? Container() : Image.file(_image),
            SizedBox(
              height: 20,
            ),
            _outputs != null
                ? Text(
              "${_outputs.toString()}",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                background: Paint()..color = Colors.white,
              ),
            )
                : Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Icon(Icons.image),
      ),
    );
  }

  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.4,       // defaults to 0.1
        numResults: 166,// defaults to 5
        asynch: true

    );
    print(output);
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
     a = await Tflite.loadModel(
      model: "assets/VGG16model.tflite",
      labels: "assets/labels.txt",
       numThreads : 1,

     );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}