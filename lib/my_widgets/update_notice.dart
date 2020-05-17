import 'package:flutter/material.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:sennit/main.dart';

class UpdateNoticeRoute extends StatelessWidget {
  final bool compulsory;
  final String version;

  UpdateNoticeRoute(this.compulsory, this.version);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Notice'),
          centerTitle: true,
          actions: compulsory
              ? null
              : <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        MyApp.initialRoute,
                      );
                    },
                  ),
                ],
        ),
        body: Card(
          margin: EdgeInsets.only(
            top: 130, left: 8.0, right: 8.0,
          ),
          elevation: 16.0,
          child: Container(
            padding: EdgeInsets.all(
              16.0,
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.info,
                  color: Theme.of(context).primaryColor,
                  size: 50,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Update Notice',
                  style: Theme.of(context).textTheme.title.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  height: 15,
                ),
                compulsory
                    ? Text(
                        '''A new version $version of the app is available.\nThis is a compulsory update.\nPlease Update Your App!''',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subhead,
                      )
                    : Text(
                        '''A new version $version is available.\nPlease update the app and get the most out of it.''',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    !compulsory
                        ? RaisedButton(
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                MyApp.initialRoute,
                              );
                            },
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        : Opacity(
                            opacity: 0,
                          ),
                    !compulsory
                        ? Spacer()
                        : Opacity(
                            opacity: 0,
                          ),
                    RaisedButton(
                      onPressed: () {
                        OpenAppstore.launch(androidAppId: 'za.co.sennit', iOSAppId: "1500676443");
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
