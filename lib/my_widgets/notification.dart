import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sennit/models/models.dart';

import '../main.dart';

class UserNotificationWidget extends StatelessWidget {
  Stream<DocumentSnapshot> getNotifications() {
    User user = Session.data['user'];
    return Firestore.instance
        .collection('userNotifications')
        .document('${user.userId}')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: getNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.data == null ||
                snapshot.data.exists ||
                snapshot.data.data == null) {
              return Center(
                child: Text(
                  'No Notifications Available',
                  style: Theme.of(context).textTheme.title,
                ),
              );
            } else {
              var keys = snapshot.data.data.keys.toList();
              keys.sort((a, b) {
                return double.parse(b).compareTo(double.parse(a));
              });

              return Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      keys.length,
                      (index) {
                        return Padding(
                          padding: EdgeInsets.all(4),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: snapshot.data.data['type'] ==
                                        UserNotification.ORDER_POSTED
                                    ? "Order Posted"
                                    : snapshot.data.data['type'] ==
                                            UserNotification.ORDER_PENDING
                                        ? "Your Order is on its Way"
                                        : "You order has been delivered, Please Rate the driver",
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              style: Theme.of(context).textTheme.title,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
