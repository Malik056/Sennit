import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:sennit/user/sendit.dart';

class StoresRoute extends StatefulWidget {
  final Address address;
  StoresRoute({@required this.address});

  @override
  State<StatefulWidget> createState() {
    return StoresRouteState(address);
  }

}

class StoresRouteState extends State<StoresRoute> {

  Address selectedAddress;
  StoresRouteState(this.selectedAddress);

  @override
  void initState() {
    super.initState(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: Icon(Icons.location_on),
          title: Text(widget.address.addressLine),
          trailing: Text(" - ASAP"),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return AddressAddingRoute(SourcePage.recieveIt, selectedAddress);
              }
            )).then((value) {
              setState(() {
                selectedAddress = value;
              });
            });
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
          ],
        ),
      ),
    );
  }
}

class StoreItem extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.network('https://picsum.photos/500', fit: BoxFit.fill,),
            SizedBox(height: 4,),
            Text('Some Store'),
            GridView.count(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                GridTile(
                  child: Image.network('https://picsum.photos/500', fit: BoxFit.fill,),
                  footer: Container(color: Colors.white, child: Text('Some Item'),),
                ),
              ],
              mainAxisSpacing: 4,
              crossAxisCount: 1,
            ),
          ],
        )
      ),
    );
  }
}
