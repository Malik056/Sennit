import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sennit/main.dart';

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sennit'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Opacity(
            opacity: 0,
            child: Container(
              height: 50,
            ),
          ),
          Image.asset(
            'assets/images/logo.png',
            width: 250,
          ),
          // Expanded(
          //   child:
          Spacer(),
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            child: Text.rich(
              TextSpan(
                text: 'About Us\n',
                style: Theme.of(context).textTheme.headline,
                children: [
                  TextSpan(
                      text:
                          '\nSennit is a unique business platform whereby both drivers and clients are able to deliver or have goods delivered respectively, with no signup costs. Sign Up now to have your goods delivered immediately!.',
                      style: Theme.of(context).textTheme.body1),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // ),
          Spacer(
            flex: 2,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: RaisedButton(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.userAlt,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'I am a User',
                  style: Theme.of(context).textTheme.subhead,
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(MyApp.userStartPage);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            width: MediaQuery.of(context).size.width,
            child: RaisedButton(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  FontAwesomeIcons.car,
                  color: Theme.of(context).accentColor,
                ),
                title: Text(
                  'I am a Driver',
                  style: Theme.of(context).textTheme.subhead,
                ),
                trailing: Icon(
                  Icons.navigate_next,
                  color: Theme.of(context).accentColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(MyApp.driverStartPage);
              },
            ),
          ),
        ],
      )),
    );
  }
}
