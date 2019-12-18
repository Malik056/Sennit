import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sennit/driver/help.dart';
import 'package:sennit/main.dart';

class DriverStartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Driver'),
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
                'assets/images/delivery.png',
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
                // color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(100, 100))),
                onPressed: () {
                  Navigator.pushNamed(context, MyApp.driverSignup);
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
                child: Text(
                  'Log in',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: Theme.of(context).textTheme.button.fontSize,
                    // color: Colors.white,
                  ),
                ),
                // color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.elliptical(100, 100))),
                onPressed: () {
                  Navigator.of(context).pushNamed(MyApp.driverSignin);
                },
              ),
              Opacity(
                opacity: 0,
                child: Container(
                  height: 15,
                ),
              ),
              GestureDetector(
                child: Text.rich(
                  TextSpan(
                    text: 'How it works as a driver? ',
                    children: [
                      TextSpan(
                        text: 'Click here.',
                        style: TextStyle(
                            decorationStyle: TextDecorationStyle.solid,
                            color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HelpRoute()));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
