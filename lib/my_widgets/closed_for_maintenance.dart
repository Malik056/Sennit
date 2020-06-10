import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:sennit/rx_models/rx_config.dart';

class ClosedForMaintenance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RxConfig rxConfig = GetIt.I.get<RxConfig>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Notice'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(FontAwesomeIcons.tools, size: 40),
                SizedBox(height: 10),
                Text(
                  'Sorry For Inconvenience!\nThe App is Closed for Maintenance',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                Text(
                  rxConfig?.config?.value['waitMessage'] != null
                      ? rxConfig?.config?.value['waitMessage']
                      : '',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
