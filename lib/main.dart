import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:temp_taker/camera_page.dart';
import 'package:temp_taker/gallery_page.dart';
import 'package:temp_taker/login_page.dart';
import 'package:temp_taker/uploader.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUS Temperature Taker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Temp Taker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _storage = new FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _tempController = TextEditingController();
  static final int AM = 0;
  static final int PM = 1;
  static final int noSymptom = 0;
  static final int hasSymptom = 1;
  var _selectedTimeOfTheDay = AM;
  var _selectedSymptom = noSymptom;
  TempDeclarer _declarer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    PermissionHandler().requestPermissions(<PermissionGroup>[
      PermissionGroup.storage,
      PermissionGroup.camera,
      PermissionGroup.photos
    ]);

    _storage.read(key: 'username').then((val) {
      if (val == null) {
        _showLoginPrompt();
      }
    });

    DateTime.now().hour < 12
        ? _selectedTimeOfTheDay = AM
        : _selectedTimeOfTheDay = PM;
  }

  void _setSelectedTimeOfTheDay(int val) {
    setState(() {
      _selectedTimeOfTheDay = val;
    });
  }

  void _setSelectedSymptom(int val) {
    setState(() {
      _selectedSymptom = val;
    });
  }

  void _showSuccessPrompt(Map<String, dynamic> data) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text(data.toString()),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              )
            ],
          );
        });
  }

  void _showLoginPrompt({String reason = "No credentials are provided."}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Action required"),
            content: Text(reason),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close')),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text('Login'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text('View photos'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GalleryPage()));
                },
              ),
              RaisedButton(
                child: Text('Take photo'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraPage(cameras.first)));
                },
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Temperature'),
                      controller: _tempController,
                      validator: (value) {
                        double num = double.parse(value);
                        if (num >= 40.0 || num <= 35.0) {
                          return 'Invalid range of temperature';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Text('AM/PM'),
                        Radio(
                          value: 0,
                          groupValue: _selectedTimeOfTheDay,
                          onChanged: (val) => _setSelectedTimeOfTheDay(val),
                        ),
                        Text('AM'),
                        Radio(
                          value: 1,
                          groupValue: _selectedTimeOfTheDay,
                          onChanged: (val) => _setSelectedTimeOfTheDay(val),
                        ),
                        Text('PM')
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Do you have any symptoms?'),
                        Radio(
                          value: 0,
                          groupValue: _selectedSymptom,
                          onChanged: (val) => _setSelectedSymptom(val),
                        ),
                        Text('No'),
                        Radio(
                          value: 1,
                          groupValue: _selectedSymptom,
                          onChanged: (val) => _setSelectedSymptom(val),
                        ),
                        Text('Yes')
                      ],
                    ),
                    RaisedButton(
                      child: Text('Submit'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          var username = await _storage.read(key: 'username');
                          var password = await _storage.read(key: 'password');
                          if (this._declarer == null)
                            this._declarer =
                                new TempDeclarer(username, password);
                          var res = await _declarer.submitTemp(
                              double.parse(_tempController.text),
                              freq: _selectedTimeOfTheDay == AM ? 'A' : 'P',
                              symptom: _selectedSymptom == hasSymptom);
                          if (res != null) {
                            _showSuccessPrompt(res);
                          } else {
                            _showLoginPrompt(
                                reason: 'Failed to submit data. '
                                    'You may check your connection, restart the app or tap "Login" to reset credentials.');
                          }
                        }
                      },
                    ),
                    RaisedButton(
                      child: Text('Reset Credentials'),
                      onPressed: () async {
                        await _storage.deleteAll();
                        _showLoginPrompt();
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
