import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            // bool result =
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewWidget(
                                  user: Session.data['user'],
                                  itemId: null,
                                  isDriver: true,
                                  driverId: data.data['driverId'],
                                  orderId: data.data['orderId'],
                                  fromNotification: true,
                                  userId: data.data['userId'],
                                ),
                              ),
                            );
                            // if (result != null && result) {
                            //   Firestore.instance
                            //       .collection('users')
                            //       .document(Session.data['user'].userId)
                            //       .collection('notifications')
                            //       .document(data.documentID)
                            //       .updateData({
                            //     'rated': true,
                            //   });
                            // }
                          }
                        },
                        splashColor:
                            Theme.of(context).primaryColor.withAlpha(128),
                        child: Card(
                          color: data.data['seen']
                              ? Color.fromARGB(255, 200, 200, 200)
                              : Colors.white,
                          // fromARGB(255, (57 * 3).floor(),
                          //     (59 * 3).floor(), (82 * 3).floor()),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: Text('${data.data['title']}\n'),
                            subtitle: Text(
                              !data.data['rated']
                                  ? data.data['message'] +
                                      '\nPlease Click to rate Driver.'
                                  : data.data['message'],
                              style: Theme.of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(fontSize: 14),
                            ),
                            trailing: Text(
                                '''${DateFormat("dd/MM/yyyy").format(DateTime.fromMillisecondsSinceEpoch(data.data['date']))}'''),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
