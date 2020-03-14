import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/review.dart';

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
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(
                    snapshot.data.documents.length,
                    (index) {
                      var data = snapshot.data.documents[index];
                      return Padding(
                        padding: EdgeInsets.all(4),
                        child: InkWell(
                          onTap: () async {
                            if (!data.data['seen']) {
                              Utils.showLoadingDialog(context);
                              await Firestore.instance
                                  .collection('users')
                                  .document(Session.data['user'].userId)
                                  .collection('notifications')
                                  .document(data.documentID)
                                  .setData({
                                'seen': true,
                              }, merge: true);
                              Navigator.pop(context);
                            }
                            if (!data.data['rated']) {
                              bool result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReviewWidget(
                                    user: null,
                                    itemId: null,
                                    driver: true,
                                    driverId: data.data['driverId'],
                                  ),
                                ),
                              );
                              if (result) {
                                Firestore.instance
                                    .collection('users')
                                    .document(Session.data['user'].userId)
                                    .collection('notifications')
                                    .document(data.documentID)
                                    .updateData({
                                  'rated': true,
                                });
                              }
                            }
                          },
                          splashColor:
                              Theme.of(context).primaryColor.withAlpha(128),
                          child: Card(
                            color: data.data['seen']
                                ? Color.fromARGB(255, 200, 200, 200)
                                : Color.fromARGB(255, (57 * 3).floor(),
                                    (59 * 3).floor(), (82 * 3).floor()),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: data.data['title'],
                                children: [
                                  TextSpan(
                                    text: !data.data['rated']
                                        ? data.data['message'] +
                                            '. Please Click to rate Driver.'
                                        : data.data['message'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subhead
                                        .copyWith(fontSize: 14),
                                  ),
                                ],
                                style: Theme.of(context).textTheme.subhead,
                              ),
                              style: Theme.of(context).textTheme.title,
                            ),
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
