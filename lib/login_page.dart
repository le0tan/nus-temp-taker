import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _storage = FlutterSecureStorage();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //TODO: implement build

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      //backgroundColor: Colors.transparent,

      body: Builder(
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your NUSNET ID';
                        }
                        if (!RegExp(r"^[eE][0-9]{7}$").hasMatch(value)) {
                          return 'Please enter the correct ID';
                        }
                        return null;
                      },
                      controller: _usernameController,
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: NiceButton(
                        "Submit",
                        () {
                          if (_formKey.currentState.validate()) {
                            _storage
                                .write(
                                    key: 'username',
                                    value: _usernameController.text)
                                .then((val) {
                              _storage
                                  .write(
                                      key: 'password',
                                      value: _passwordController.text)
                                  .then((val) {
                                Navigator.of(context).pop();
                              });
                            });
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
          //]);
        },
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
          )),
      // button color
      onPressed: onPressed,
    );
  }
}
