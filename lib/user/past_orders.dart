import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PastOrdersRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("userOrders").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data == null ||
            !snapshot.hasData ||
            snapshot.data.documents == null ||
            snapshot.data.documents.isEmpty) {
          return Center(
            child: Text('No Past Orders Yet'),
          );
        } else {
          return Column(
            children: List.generate(
              snapshot.data.documents.length,
              (index) {
                return PastOrderTile(snapshot.data.documents[index]);
              },
            ),
          );
        }
      },
    );
  }
}

class PastOrderTile extends StatelessWidget {
  final DocumentSnapshot snapshot;
  PastOrderTile(this.snapshot);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 8,
      child: Container(
        margin: EdgeInsets.all(16),
        // padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 4,
            ),
            Text('OrderId: ${snapshot.documentID}'),
            SizedBox(
              height: 4,
            ),
            snapshot.data['sleevedRequred'] == null
                ? Text('# of itmes: ${(snapshot.data['items'] as List).length}')
                : Text('# of boxes: ${snapshot.data['numberOfBoxes']}'),
            SizedBox(
              height: 4,
            ),
            snapshot.data['sleevedRequred'] == null
                ? Text('${listToString(snapshot.data['items'])}')
                : Text('Box Size: ${snapshot.data['boxSize']}'),
            SizedBox(
              height: 4,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Price: R${snapshot.data['price']})',
                style: Theme.of(context).textTheme.subhead,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String listToString(List<String> names) {
    String allNames = "";
    for (String name in names) {
      allNames += '$name,';
    }
    allNames.replaceRange(allNames.length - 1, null, '\0');
    return allNames;
  }
}
