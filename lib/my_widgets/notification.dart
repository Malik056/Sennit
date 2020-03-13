import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sennit/models/models.dart';

import '../main.dart';

class UserNotificationWidget extends StatelessWidget {
  Stream<QuerySnapshot> getNotifications() {
    User user = Session.data['user'];
    return Firestore.instance
        .collection('users')
        .document('${user.userId}')
        .collection('notifications')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data == null ||
              snapshot.data.documents == null ||
              snapshot.data.documents.length <= 0) {
            return Center(
              child: Text(
                'No Notifications Available',
                style: Theme.of(context).textTheme.title,
              ),
            );
          } else {
            var keys = snapshot.data.documents;

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
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: snapshot.data.documents[index]
                                          .data['rated'] ==
                                      UserNotification.ORDER_POSTED
                                  ? snapshot.data.documents[index]
                                          .data['message'] +
                                      '. Please Click to rate Driver.'
                                  : snapshot
                                      .data.documents[index].data['message'],
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
    );
  }
}
