import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:temp_taker/camera_page.dart';
import 'package:temp_taker/gallery_page.dart';
import 'package:temp_taker/login_page.dart';
import 'package:temp_taker/record_page.dart';
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

  void _showLoginPrompt({String reason = "You will be directed to login in page. The previous credential will be cleared."}) {
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

  Future<TempDeclarer> getDeclarer() async {
    if (this._declarer == null) {
      var username = await _storage.read(key: 'username');
      var password = await _storage.read(key: 'password');
      this._declarer = new TempDeclarer(username, password);
    } else {
      return this._declarer;
    }
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            sideButton(
                              context,
                              Icons.person,
                              () async {
                                await _storage.deleteAll();
                                _showLoginPrompt();
                              },
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: MediaQuery.of(context).size.height *
                                        0.275,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Colors.orange,
                                                Colors.blueGrey,
                                              ])),
                                    )),
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    child: new RaisedButton(
                                      elevation: 0.0,
                                      color: Colors.white,
                                      child: new Text(
                                        "Submit",
                                        style: TextStyle(
                                            fontFamily: "Bebas Neue",
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      shape: new CircleBorder(),
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          var declarer = await getDeclarer();
                                          var res = await declarer.submitTemp(
                                              double.parse(
                                                  _tempController.text),
                                              freq: _selectedTimeOfTheDay == AM
                                                  ? 'A'
                                                  : 'P',
                                              symptom: _selectedSymptom ==
                                                  hasSymptom);
                                          if (res != null) {
                                            _showSuccessPrompt(res);
                                          } else {
                                            _showLoginPrompt(
                                                reason:
                                                    'Failed to submit data. '
                                                    'You may check your connection, restart the app or tap "Login" to reset credentials.');
                                          }
                                        }
                                      },
                                    )),
                              ],
                            ),
                            sideButton(
                              context,
                              Icons.camera_enhance,
                              () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CameraPage(cameras.first)));
                              },
                            ),
                          
                          ],
                        ),
                      ),
                      Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              NiceButton("View Photos",  () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => GalleryPage()));
                  },),
                       NiceButton("View Records", () async {
                          var declarer = await getDeclarer();
                          var html = await declarer.getRecords();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RecordPage(html)));
                        },)
                            ],
                          )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

var _signinTextStyle =
    (BuildContext context) => Theme.of(context).textTheme.subhead;

class NiceButton extends StatelessWidget {
  final String name;
  final Function onPressed;
  NiceButton(this.name, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      child: Text(
        name,
        style: _signinTextStyle(context),
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Colors.blueGrey,
          width: 3.0,
        )
      ),
      // button color
      onPressed: onPressed,
    );
  }
}

Widget sideButton(BuildContext context, IconData icon, Function onTap) {
  return ClipOval(
    child: Material(
      color: Colors.orange, // button color
      child: InkWell(
        splashColor: Colors.deepOrange, // inkwell color
        child: SizedBox(width: 50, height: 50, child: Icon(icon)),
        onTap: onTap,
      ),
    ),
  );
}
