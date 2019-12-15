import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sennit/main.dart';

class DriverSignInRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Driver Log In',
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: DriverSignIn(),
      ),
    );
  }
}

class DriverSignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DriverSignInState();
  }
}

class _DriverSignInState extends State<DriverSignIn> {
  bool rememberMeChecked = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                // style: Theme.of(context).textTheme.body1,
                validator: (email) {
                  if (email.isEmpty) {
                    return "Email can't be empty";
                  } else {
                    RegExp re = RegExp(
                        r'^[a-zA-Z0-9]+(.([a-zA-Z0-9])+)*[a-zA-Z0-9]+@[a-zA-Z]+(.[a-zA-Z]+)+$',
                        caseSensitive: false,
                        multiLine: false);
                    if (!re.hasMatch(email)) {
                      return 'Invalid Email Format';
                    }
                  }
                  return null;
                },
              ),
              TextFormField(
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                maxLines: 1,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (password) {
                  if (password.isEmpty) {
                    return "Please enter a password";
                  } else if (password.length < 6) {
                    return "Your password should be at least 6 characters long";
                  }
                  return null;
                },
              ),
              Opacity(
                opacity: 0,
                child: Container(
                  height: 15,
                ),
              ),
              GestureDetector(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        !rememberMeChecked
                            ? FontAwesomeIcons.circle
                            : FontAwesomeIcons.solidCheckCircle,
                        size: 18,
                      ),
                      Text(' Remember me'),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      rememberMeChecked = !rememberMeChecked;
                    });
                  },),
              Opacity(
                opacity: 0,
                child: Container(
                  height: 20,
                ),
              ),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(100, 100))),
                onPressed: () {
                  Navigator.of(context).popAndPushNamed(MyApp.driverHome);
                },
                padding:
                    EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 10),
                color: Theme.of(context).accentColor,
                child: Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.button.fontSize,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
