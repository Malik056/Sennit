import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sennit/main.dart';

class UserStartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pop(context);
        // Navigator.of(context).popAndPushNamed(MyApp.startPage);
        return true;
      },
        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('User'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Opacity(
                  opacity: 0,
                  child: Container(
                    height: 40,
                  ),
                ),
                Image.asset(
                  'assets/images/user.png',
                  width: 200,
                  color: Theme.of(context).accentColor,
                ),
                Opacity(
                  opacity: 0,
                  child: Container(
                    height: 80,
                  ),
                ),
                RaisedButton(
                  padding:
                      EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 10),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Theme.of(context).textTheme.button.fontSize),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(100, 100))),
                  onPressed: () {
                    Navigator.of(context).pushNamed(MyApp.userSignup);
                  },
                ),
                Opacity(
                  opacity: 0,
                  child: Container(
                    height: 10,
                  ),
                ),
                RaisedButton(
                  color: Colors.white,
                  padding:
                      EdgeInsets.only(left: 60, right: 60, top: 10, bottom: 10),
                  // color: Theme.of(context).accentColor,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: Theme.of(context).textTheme.button.fontSize,
                      // color: Colors.white //Theme.of(context).primaryColor,
                    ),
                  ),
                  // color: Theme.of(context).accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(100, 100))),
                  onPressed: () {
                    Navigator.of(context).pushNamed(MyApp.userSignIn);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
