import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HelpRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Help'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 30),
                child: Text(
                  'How Does It Work As a Driver? ',
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
            ),
            Opacity(
              opacity: 0,
              child: Container(
                height: 30,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Step 1: Register with Us',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      height: 10,
                    ),
                  ),
                  Image.asset('assets/images/register.png'),
                ],
              ),
            ),
            Opacity(
              opacity: 0,
              child: Container(
                height: 10,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Step 2: Wait for Validation',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Image.asset('assets/images/wait.png'),
                ],
              ),
            ),
            Opacity(
              opacity: 0,
              child: Container(
                height: 10,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(bottom: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Step 3: Start Delivering And Earn 75% Off The Profit Of Each Trip',
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  Image.asset('assets/images/deliver.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
