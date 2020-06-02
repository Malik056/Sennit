import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:sennit/main.dart';
import 'package:sennit/rx_models/rx_config.dart';

class UpdateNoticeRoute extends StatelessWidget {
  UpdateNoticeRoute();

  @override
  Widget build(BuildContext context) {
    RxConfig rxConfig = GetIt.I.get<RxConfig>();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Notice'),
          centerTitle: true,
          actions: rxConfig.config.value['compulsory']
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
            top: 130,
            left: 8.0,
            right: 8.0,
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
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(
                  height: 15,
                ),
                rxConfig.config.value['compulsory']
                    ? Text(
                        '''A new version ${rxConfig.config.value['versionName']} (${rxConfig.config.value['versionCode']}) of the app is available.\nThis is a compulsory update.\nPlease Update Your App!''',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      )
                    : Text(
                        '''A new version ${rxConfig.config.value['versionName']} (${rxConfig.config.value['versionCode']}) is available.\nPlease update the app and get the most out of it.''',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    !rxConfig.config.value['compulsory']
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
                    !rxConfig.config.value['compulsory']
                        ? Spacer()
                        : Opacity(
                            opacity: 0,
                          ),
                    RaisedButton(
                      onPressed: () {
                        OpenAppstore.launch(
                            androidAppId: 'za.co.sennit',
                            iOSAppId: "1500676443");
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
