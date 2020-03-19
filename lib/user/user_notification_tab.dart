import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/review.dart';

class NotificationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Session.data['user'];

    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("notifications")
          .document(user.userId)
          .snapshots(),
      initialData: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.data.exists ||
            snapshot.data.data.isEmpty ||
            snapshot.data.data.keys.length <= 0) {
          return Center(
            child: Text('No Notifications'),
          );
        } else {
          var keys = snapshot.data.data.keys.toList();

          return Column(
              children: List<Widget>.generate(keys.length, (index) {
            Map<String, dynamic> notification = snapshot.data.data[keys[index]];
            return notification['status'] == "posted"
                ? ListTile(
                    title: Text('Your Order is on its way'),
                    subtitle: Text(
                        'Contents: ${snapshot.data.data[keys[index]]['contents']}'),
                    onTap: () {},
                  )
                : ListTile(
                    title: Text('Your Order has Been Delivered'),
                    subtitle: Text('Tap to Rate the Driver'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ReviewWidget(
                            orderId: notification['orderId'],
                            user: user,
                            itemId: "",
                            isDriver: true,
                            driverId: notification['driverId'],
                          );
                        },
                      ));
                    },
                  );
          }));
        }
      },
    );
  }
}
