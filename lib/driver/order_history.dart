import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sennit/main.dart';
import 'package:sennit/models/models.dart';
import 'package:sennit/my_widgets/order_details.dart';

class OrderHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance
          .collection("orders")
          .where('driverId',
              isEqualTo: (Session.data['driver'] as Driver).driverId)
          // .document((Session.data['driver'] as Driver).driverId)
          // .collection('orders')
          .getDocuments(),
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
          final documents = snapshot.data.documents;
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: List.generate(
                documents.length,
                (index) {
                  final data = snapshot.data.documents[index].data;
                  data.update(('orderId'),
                      (old) => snapshot.data.documents[index].documentID,
                      ifAbsent: () =>
                          snapshot.data.documents[index].documentID);
                  return OrderTile(data: data);
                },
              ),
            ),
          );
        }
      },
    );
  }
}

// class _SennitOrderTile extends StatelessWidget {
//   final data;

//   const _SennitOrderTile({Key key, this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     Widget card = Card(
//       child: Container(
//         margin: EdgeInsets.all(10.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Sennit',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//             SizedBox(
//               height: 14.0,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 SizedBox(
//                   width: 4.0,
//                 ),
//                 Expanded(
//                   flex: 4,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(
//                         'Order ID',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 6.0,
//                       ),
//                       Text(
//                         data['orderId'],
//                         textAlign: TextAlign.start,
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   width: 4.0,
//                 ),
//                 Center(
//                   child: Container(
//                     height: 50,
//                     width: 1,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 4.0,
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text(
//                           'Price',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 6.0,
//                         ),
//                         Text(
//                           "${data['orderPrice']}R",
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 4.0,
//                 ),
//                 Center(
//                   child: Container(
//                     height: 50,
//                     width: 1,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 4.0,
//                 ),
//                 Expanded(
//                   flex: 4,
//                   child: Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text(
//                           '# of Boxes',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 6.0,
//                         ),
//                         Text(
//                           '${data['numberOfBoxes']} ${data['boxSize']} Boxes',
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 4.0,
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 14.0,
//             ),
//             Row(
//               children: <Widget>[
//                 Container(
//                   padding: EdgeInsets.all(2),
//                   margin: EdgeInsets.only(left: 2, right: 4),
//                   decoration: ShapeDecoration(
//                     color: Theme.of(context).primaryColor,
//                     shape: Border(
//                       right: BorderSide(
//                         color: Theme.of(context).primaryColor,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   child: RotatedBox(
//                     quarterTurns: 3,
//                     child: Center(
//                       child: Text(
//                         ' P i c k u p ',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     data['pickUpAddress'],
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(2),
//                   margin: EdgeInsets.only(left: 2, right: 4),
//                   decoration: ShapeDecoration(
//                     color: Theme.of(context).primaryColor,
//                     shape: Border(
//                       right: BorderSide(
//                         color: Theme.of(context).primaryColor,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   child: RotatedBox(
//                     quarterTurns: 3,
//                     child: Center(
//                       child: Text(
//                         ' D r o p Off ',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     data['dropOffAddress'],
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 10,
//             ),
//           ],
//         ),
//       ),
//       elevation: 10,
//     );
//     return card;
//   }
// }

// class SennitOrderInformationRoute extends StatelessWidget {
//   final data;

//   const SennitOrderInformationRoute({Key key, this.data}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Sennit Order"),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         minimum: EdgeInsets.all(8.0),
//         child: Column(
//           children: <Widget>[
//             Card(
//               child: Container(
//                 margin: EdgeInsets.all(4.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: <Widget>[
//                     SizedBox(
//                       height: 6,
//                     ),
//                     Text(
//                       'Order Id: ${data['orderId']}',
//                       style: Theme.of(context).textTheme.subtitle1,
//                     ),
//                     SizedBox(
//                       height: 6,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Text(
//                           'Picked From:',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                         Expanded(
//                           child: Text(
//                             '${data['pickUpAddress']}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Text(
//                           'Drop Off:',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                         Expanded(
//                           child: Text(
//                             '${data['dropOffAddress']}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Text(
//                           'Boxes: ',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                         Expanded(
//                           child: Text(
//                             '${data['numberOfBoxes'] + ' ' + data['boxSize'] + ' Boxes'}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Text(
//                           'Sleeves Required',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                         Expanded(
//                           child: Text(
//                             '${data['sleevesRequired'] ? 'YES' : 'NO'}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Expanded(
//                           child: Text(
//                             'Receiver Email: ',
//                             style: Theme.of(context).textTheme.subtitle1,
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '${data['receiverEmail']}',
//                           ),
//                         ),
//                         Expanded(
//                           child: Text(
//                             'Receiver Phone: ',
//                             style: Theme.of(context).textTheme.subtitle1,
//                           ),
//                         ),
//                         Expanded(
//                           flex: 2,
//                           child: Text(
//                             '${data['receiverPhone']}',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Text(
//                           '${data['dropToDoor'] ? 'Picked From Door' : 'Met at Vehicle'}',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Text(
//                           'Total Distance',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                         Expanded(
//                           child: Text(
//                             '''${Utils.calculateDistance(
//                               Utils.latLngFromString(data['pickUpLatLng']),
//                               Utils.latLngFromString(data['dropOffLatLng']),
//                             )} KM''',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: <Widget>[
//                         Text(
//                           'Total Bill: ',
//                           style: Theme.of(context).textTheme.subtitle1,
//                         ),
//                         Expanded(
//                           child: Text(
//                             'R${(data['orderPrice'] as double).toStringAsFixed(1)}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PastOrderTile extends StatelessWidget {
//   final DocumentSnapshot snapshot;
//   PastOrderTile(this.snapshot);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       elevation: 8,
//       child: Container(
//         margin: EdgeInsets.all(16),
//         // padding: EdgeInsets.all(8),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             SizedBox(
//               height: 4,
//             ),
//             Text('OrderId: ${snapshot.documentID}'),
//             SizedBox(
//               height: 4,
//             ),
//             snapshot.data['sleevedRequired'] == null
//                 ? Text('# of items: ${(snapshot.data['items'] as List).length}')
//                 : Text('# of boxes: ${snapshot.data['numberOfBoxes']}'),
//             SizedBox(
//               height: 4,
//             ),
//             snapshot.data['sleevedRequired'] == null
//                 ? Text('${listToString(snapshot.data['items'])}')
//                 : Text('Box Size: ${snapshot.data['boxSize']}'),
//             SizedBox(
//               height: 4,
//             ),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Text(
//                 'Price: R${snapshot.data['price']})',
//                 style: Theme.of(context).textTheme.subtitle1,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String listToString(List<String> names) {
//     String allNames = "";
//     for (String name in names) {
//       allNames += '$name,';
//     }
//     allNames.replaceRange(allNames.length - 1, null, '\0');
//     return allNames;
//   }
// }
