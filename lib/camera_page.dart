import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class CameraPage extends StatefulWidget {
  final CameraDescription camera;
  CameraPage(this.camera);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CameraPageState();
  }
}

class _CameraPageState extends State<CameraPage> {
  CameraController _cameraController;
  GlobalKey _scaffoldKey = GlobalKey();
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _cameraController =
        CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Taking Picture'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_cameraController);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) => FloatingActionButton(
          child: Icon(Icons.camera),
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final path = join(
                (await getApplicationDocumentsDirectory()).path,
                '${DateTime.now().toIso8601String()}.png',
              );
              await _cameraController.takePicture(path);
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Success!'),
              ));
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController?.dispose();
    super.dispose();
  }
}