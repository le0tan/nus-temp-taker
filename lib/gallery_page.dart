import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class GalleryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GalleryPageState();
  }
}

class _GalleryPageState extends State<GalleryPage> {
  Future<Directory> _directoryFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _directoryFuture = getApplicationDocumentsDirectory();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('View photos'),
      ),
      body: FutureBuilder(
        future: _directoryFuture,
        builder: (BuildContext context, AsyncSnapshot<Directory> snapshot) {
          if (snapshot.hasData) {
            var dir = snapshot.data;
            var fileList = dir.listSync();
            return ListView.builder(
              itemCount: fileList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: ListTile(
                    leading: Image.file(File(fileList[index].path)),
                    title: Text(fileList[index].toString()),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(
                              imagePath: fileList[index].path),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Text('loading...');
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
