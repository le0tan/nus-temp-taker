import 'package:flutter/material.dart';

class SubmitPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SubmitPageState();
  }
}

class _SubmitPageState extends State<SubmitPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Temp Submit'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return Center(
            child: Text('haha'),
          );
        },
      ),
    );
  }
}
