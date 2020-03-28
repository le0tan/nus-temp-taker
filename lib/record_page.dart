import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;

class RecordPage extends StatefulWidget {
  final String html;
  RecordPage(this.html);
  @override
  State<StatefulWidget> createState() {
    return _RecordPageState();
  }
}

class _RecordPageState extends State<RecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Records'),
      ),
      body: Builder(
        builder: (BuildContext context) {
          var rows = parse(widget.html)
              .getElementById('myTable')
              .getElementsByTagName('tr');
          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (BuildContext context, int index) {
              var rawText =
                  rows[index].text.replaceAll('\t', '').replaceAll(' ', '');
              return Card(
                child: Text(rawText
                    .split('\n')
                    .where((val) => val.isNotEmpty)
                    .toList()
                    .toString()),
              );
            },
          );
        },
      ),
    );
  }
}
