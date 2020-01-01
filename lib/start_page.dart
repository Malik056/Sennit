import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sennit/main.dart';

class StartPage extends StatelessWidget {
  StartPage();
  static bool _willExit = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_willExit) {
          SystemNavigator.pop();
        } else {
          BotToast.showText(text: 'Press Again to Exit');
          _willExit = true;
          Future.delayed(Duration(seconds: 3)).then((value) {
            _willExit = false;
          });
        }
        return false;
      },
      child: Scaffold(
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
            Expanded(
              child: Image.asset(
                'assets/images/logo.png',
              ),
            ),
            // Expanded(
            //   child:
            Container(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Text.rich(
                TextSpan(
                  text: 'About Us\n',
                  style: MediaQuery.of(context).size.height <
                          800 / MediaQuery.of(context).devicePixelRatio
                      ? Theme.of(context).textTheme.subhead
                      : Theme.of(context).textTheme.headline,
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
              flex: 1,
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(MyApp.driverStartPage);
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}
